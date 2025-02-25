/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';

import '../../../components/editor/cell_editor/referenced_cell_editor.dart';
import '../../../flutter_ui.dart';
import '../../../model/command/api/fetch_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/save_fetch_data_command.dart';
import '../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/data/data_book.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/response/dal_data_provider_changed_response.dart';
import '../../../model/response/dal_meta_data_response.dart';
import '../../../model/response/record_format.dart';
import '../../../util/column_list.dart';
import '../../api/shared/api_object_property.dart';
import '../../command/i_command_service.dart';
import '../../service.dart';
import '../i_data_service.dart';

class DataService implements IDataService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all DataBooks with dataProvider as key
  HashMap<String, DataBook> dataBooks = HashMap();

  /// Map of all currently fetching data books with dataProvider as key and value is the row to fetch to.
  HashMap<String, int> fetchingDataBooks = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization",
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates an [DataService] Instance
  DataService.create();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FutureOr<void> clear(ClearReason reason) {
    clearDataBooks();
  }

  @override
  List<BaseCommand> updateFromFetch({required SaveFetchDataCommand pCommand}) {
    DataBook dataBook =
        dataBooks[pCommand.response.dataProvider] ??= DataBook(dataProvider: pCommand.response.dataProvider);

    if (pCommand.response.clear) {
      dataBook.clearRecords();
      dataBook.selectedRow = -1;
    }

    dataBook.updateFromFetch(pCommand: pCommand);

    return [];
  }

  @override
  bool updateDataChanged({required DalDataProviderChangedResponse pChangedResponse}) {
    DataBook? dataBook = dataBooks[pChangedResponse.dataProvider];
    if (dataBook == null) {
      return false;
    }

    return dataBook.updateDataChanged(pChangedResponse: pChangedResponse);
  }

  @override
  bool updateSelectionChanged({required DalDataProviderChangedResponse pChangedResponse}) {
    DataBook? dataBook = dataBooks[pChangedResponse.dataProvider];
    if (dataBook == null) {
      return false;
    }

    bool changed = false;

    if (pChangedResponse.json.containsKey(ApiObjectProperty.selectedColumn)) {
      changed = true;
      dataBook.selectedColumn = pChangedResponse.selectedColumn;
    }

    if (pChangedResponse.json.containsKey(ApiObjectProperty.selectedRow) && pChangedResponse.selectedRow != null) {
      changed = true;
      dataBook.selectedRow = pChangedResponse.selectedRow!;
    }

    if (pChangedResponse.json.containsKey(ApiObjectProperty.treePath) && pChangedResponse.treePath != null) {
      changed = true;
      dataBook.selectedRow = pChangedResponse.treePath!.last;
      dataBook.treePath = pChangedResponse.treePath;
    }

    return changed;
  }

  @override
  bool updateMetaData({required DalMetaDataResponse pChangedResponse}) {
    DataBook? dataBook = dataBooks[pChangedResponse.dataProvider];

    if (dataBook == null) {
      dataBook = DataBook(
        dataProvider: pChangedResponse.dataProvider,
        records: HashMap(),
        isAllFetched: false,
        selectedRow: -1,
      );
      dataBooks[dataBook.dataProvider] = dataBook;
    }

    dataBook.metaData = (dataBook.metaData ?? DalMetaData(pChangedResponse.dataProvider))
      ..applyMetaDataResponse(pChangedResponse);

    return true;
  }

  @override
  bool setMetaData({required DalMetaData pMetaData}) {
    DataBook? dataBook = dataBooks[pMetaData.dataProvider];

    if (dataBook == null) {
      dataBook = DataBook(
        dataProvider: pMetaData.dataProvider,
        records: HashMap(),
        isAllFetched: false,
        selectedRow: -1,
      );
      dataBooks[dataBook.dataProvider] = dataBook;
    }

    dataBook.metaData = pMetaData;

    pMetaData.columnDefinitions.forEach((colDef) {
      if (colDef.cellEditorModel is FlLinkedCellEditorModel) {
        IDataService().createReferencedCellEditors(
            colDef.cellEditorModel as FlLinkedCellEditorModel, pMetaData.dataProvider, colDef.name);
      }
    });

    return true;
  }

  @override
  bool updateMetaDataChanged({required DalDataProviderChangedResponse pChangedResponse}) {
    DalMetaData? metaData = dataBooks[pChangedResponse.dataProvider]?.metaData;

    if (metaData == null) {
      return false;
    }

    return metaData.applyMetaDataFromChangedResponse(pChangedResponse);
  }

  @override
  DataRecord? getSelectedRowData({
    required List<String>? pColumnNames,
    required String pDataProvider,
  }) {
    DataBook dataBook = dataBooks[pDataProvider]!;

    DataRecord? selectedRowColumnData = dataBook.getSelectedRecord(pDataColumnNames: pColumnNames);

    return selectedRowColumnData;
  }

  @override
  DataChunk getDataChunk({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
    List<String>? pColumnNames,
    String? pPageKey,
    bool pFromStart = false
  }) {
    // Get data from all requested columns
    List<ColumnDefinition> columnDefinitions = [];
    List<int> colDefIndexes = [];

    DataBook dataBook = dataBooks[pDataProvider]!;

    // Get data from data book and add column definitions in correct order -
    // either same as requested or as received from server
    if (dataBook.metaData != null) {
      if (pColumnNames != null) {
        for (String columnName in pColumnNames) {
          ColumnDefinition? colDef = dataBook.metaData!.columnDefinitions.byName(columnName);

          if (colDef != null) {
            columnDefinitions.add(colDef);
          } else {
            throw Exception("Column $columnName not found in metadata of $pDataProvider");
          }
        }
      } else {
        columnDefinitions.addAll(dataBook.metaData!.columnDefinitions);
      }
    }

    for (int i = 0; i < columnDefinitions.length; i++) {
      ColumnDefinition colDef = columnDefinitions[i];
      colDefIndexes.add(dataBook.metaData!.columnDefinitions.indexOf(colDef));
    }

    // Build rows out of column data
    Map<int, List<dynamic>> resultData = HashMap();
    Map<int, List<bool>> resultReadOnly = HashMap();
    Map<String, RecordFormat> resultRecordFormats = HashMap();

    Map<int, List<dynamic>> currentDataMap = pPageKey != null ? (dataBook.pageRecords[pPageKey] ?? HashMap()) : dataBook.records;
    int toIndex = min(pTo ?? currentDataMap.length, currentDataMap.length);

    for (int i = pFrom; i < toIndex; i++) {
      var resultRow = List<dynamic>.filled(columnDefinitions.length + 1, null);
      var dataRow = currentDataMap[i]!;

      columnDefinitions.forEachIndexed((index, colDef) {
        resultRow[index] = dataRow[colDefIndexes[index]];
      });

      resultRow.last = dataRow.last;
      resultData[i] = resultRow;

      //currently, the formats are not saved per page, so we can't support it
      if (pPageKey == null) {
        List<bool>? readOnlyFormat = dataBook.recordReadOnly[i];

        //use only readonly information of matching records

        if (readOnlyFormat != null) {
          resultReadOnly[i] = readOnlyFormat;
        }

        //use only formats of matching records

        RecordFormat formats;
        RecordFormat? formatsNew;
        RowFormat? rowformat;

        for (String key in dataBook.recordFormats.keys) {
          formats = dataBook.recordFormats[key]!;

          rowformat = formats.rowFormats[i];

          if (rowformat != null) {
            formatsNew = resultRecordFormats[key];

            if (formatsNew == null) {
              formatsNew = RecordFormat();

              resultRecordFormats[key] = formatsNew;
            }

            formatsNew.rowFormats[i] = rowformat;
          }
        }
      }
    }

    return DataChunk(
      data: resultData,
      //this chunk is only all fetched if it contains all records
      isAllFetched: dataBook.isAllFetched && resultData.length == currentDataMap.length,
      columnDefinitions: ColumnList(columnDefinitions),
      from: pFrom,
      recordFormats: resultRecordFormats,
      dataReadOnly: resultReadOnly,
      fromStart: pFromStart
    );
  }

  @override
  DalMetaData? getMetaData(String pDataProvider) {
    return dataBooks[pDataProvider]?.metaData;
  }

  @override
  bool dataBookNeedsFetch({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
  }) {
    if (pFrom <= -1) {
      return false;
    }

    if (!dataBooks.containsKey(pDataProvider)) {
      return true;
    }

    DataBook dataBook = dataBooks[pDataProvider]!;

    // If all has already been fetched, then there is no point in fetching more,
    // If not all data is fetched and pTo is null (all possible data is being requested), more should be fetched
    if (dataBook.isAllFetched) {
      return false;
    } else if ((pTo == null || pTo == -1)) {
      return !fetchingDataBooks.containsKey(pDataProvider) || fetchingDataBooks[pDataProvider] != -1;
    }

    // Check all indexes if they are present.
    for (int i = pFrom; i < pTo; i++) {
      var record = dataBook.records[i];
      if (record == null) {
        return !fetchingDataBooks.containsKey(pDataProvider) || pTo > (fetchingDataBooks[pDataProvider]!);
      }
    }

    // Returns false if all needed rows are already fetched.
    return false;
  }

  @override
  bool deleteDataFromDataBook({
    required String pDataProvider,
    required int? pFrom,
    required int? pTo,
    required bool? pDeleteAll,
  }) {
    // Get data book and return false if it does not exist
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null) {
      return false;
    }
    // If delete all flag is set just clear all records
    if (pDeleteAll == true) {
      dataBook.clearRecords();
      return true;
    }
    // Clear only records in given range
    if (pFrom != null && pTo != null) {
      dataBook.deleteRecordRange(pFrom: pFrom, pTo: pTo);
      return true;
    }
    return false;
  }

  @override
  bool setSelectedRow({required String pDataProvider, required int pNewSelectedRow, String? pNewSelectedColumn}) {
    // get data book, if null return false
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null) {
      return false;
    }
    // set selected row
    dataBook.selectedRow = pNewSelectedRow;
    dataBook.selectedColumn = pNewSelectedColumn;
    return true;
  }

  @override
  void clearData(String pWorkScreen) {
    FlutterUI.logUI.i("Clearing all data books of prefix: $pWorkScreen");
    FlutterUI.logUI.i("Pre clearing: ${dataBooks.values}");
    dataBooks.removeWhere((key, value) => key.startsWith(pWorkScreen, key.indexOf("/") + 1));
    FlutterUI.logUI.i("Post clearing: ${dataBooks.values}");
  }

  @override
  void clearDataBooks() {
    return dataBooks.clear();
  }

  @override
  HashMap<String, DataBook> getDataBooks() {
    return HashMap.of(dataBooks);
  }

  @override
  DataBook? getDataBook(String pDataProvider) {
    return dataBooks[pDataProvider];
  }

  @override
  ReferencedCellEditor createReferencedCellEditors(
      FlLinkedCellEditorModel cellEditorModel, String dataProvider, String columnName) {
    var linkReference = cellEditorModel.linkReference;

    DataBook referencedDataBook =
        dataBooks[linkReference.referencedDataBook] ??= DataBook(dataProvider: linkReference.referencedDataBook);

    ReferencedCellEditor referencedCellEditor = ReferencedCellEditor(cellEditorModel, columnName, dataProvider);

    referencedDataBook.referencedCellEditors.add(referencedCellEditor);

    if (linkReference.columnNames.isEmpty && linkReference.referencedColumnNames.isNotEmpty) {
      linkReference.columnNames.add(columnName);
    }

    var dataBook = getDataBook(linkReference.referencedDataBook);
    if (dataBookNeedsFetch(pFrom: 0, pDataProvider: linkReference.referencedDataBook, pTo: -1) ||
        (dataBook != null && dataBook.metaData == null)) {
      ICommandService().sendCommand(
        FetchCommand(
          includeMetaData: true,
          fromRow: 0,
          rowCount: -1,
          dataProvider: linkReference.referencedDataBook,
          reason: "Created referenced cell editor on data book without metadata",
        ),
      );
    } else {
      referencedCellEditor.buildDataToDisplayMap(referencedDataBook);
    }

    return referencedCellEditor;
  }

  @override
  void setDataBookFetching(String pDataProvider, int pTo) {
    fetchingDataBooks[pDataProvider] = pTo;
  }

  @override
  void removeDataBookFetching(String pDataProvider, int pTo) {
    if (fetchingDataBooks[pDataProvider] == pTo) {
      fetchingDataBooks.remove(pDataProvider);
    }
  }
}
