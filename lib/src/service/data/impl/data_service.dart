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
import 'package:flutter/foundation.dart';

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
  Future<List<BaseCommand>> updateFromFetch({required SaveFetchDataCommand command}) async {
    DataBook dataBook = dataBooks[command.response.dataProvider] ??= DataBook(dataProvider: command.response.dataProvider);

    if (command.response.clear) {
      dataBook.clearRecords();
      dataBook.selectedRow = -1;
    }

    await dataBook.updateFromFetch(command: command);

    return [];
  }

  @override
  bool updateDataChanged({required DalDataProviderChangedResponse changedResponse}) {
    DataBook? dataBook = dataBooks[changedResponse.dataProvider];
    if (dataBook == null) {
      return false;
    }

    return dataBook.updateDataChanged(changedResponse: changedResponse);
  }

  @override
  bool updateSelectionChanged({required DalDataProviderChangedResponse changedResponse}) {
    DataBook? dataBook = dataBooks[changedResponse.dataProvider];
    if (dataBook == null) {
      return false;
    }

    bool changed = false;

    if (changedResponse.json.containsKey(ApiObjectProperty.selectedColumn)) {
      changed = dataBook.selectedColumn != changedResponse.selectedColumn;

      if (changed) {
        dataBook.selectedColumn = changedResponse.selectedColumn;
      }
    }

    if (changedResponse.json.containsKey(ApiObjectProperty.selectedRow) && changedResponse.selectedRow != null) {
      changed |= dataBook.selectedRow != changedResponse.selectedRow!;

      if (changed) {
        dataBook.selectedRow = changedResponse.selectedRow!;
      }
    }

    if (changedResponse.json.containsKey(ApiObjectProperty.treePath) && changedResponse.treePath != null) {
      changed |= !listEquals(dataBook.treePath, changedResponse.treePath);

      if (changed) {
        dataBook.treePath = changedResponse.treePath;
        dataBook.selectedRow = changedResponse.treePath!.last;
      }
    }

    return changed;
  }

  @override
  bool updateMetaData({required DalMetaDataResponse changedResponse}) {
    DataBook? dataBook = dataBooks[changedResponse.dataProvider];

    if (dataBook == null) {
      DalMetaData metaData = DalMetaData(changedResponse.dataProvider);
      metaData.applyMetaDataResponse(changedResponse);

      dataBook = DataBook(
        dataProvider: changedResponse.dataProvider,
        metaData: metaData
      );

      dataBooks[dataBook.dataProvider] = dataBook;
    }
    else {
      dataBook.metaData ??= DalMetaData(changedResponse.dataProvider);
      dataBook.metaData!.applyMetaDataResponse(changedResponse);
    }

    return true;
  }

  @override
  bool setMetaData(DalMetaData metaData) {
    DataBook? dataBook = dataBooks[metaData.dataProvider];

    if (dataBook == null) {
      dataBook = DataBook(
        dataProvider: metaData.dataProvider,
        metaData: metaData
      );

      dataBooks[dataBook.dataProvider] = dataBook;
    }
    else {
      dataBook.metaData = metaData;
    }

    metaData.columnDefinitions.forEach((colDef) {
      if (colDef.cellEditorModel is FlLinkedCellEditorModel) {
        IDataService().createReferencedCellEditors(
            colDef.cellEditorModel as FlLinkedCellEditorModel, metaData.dataProvider, colDef.name);
      }
    });

    return true;
  }

  @override
  bool updateMetaDataChanged({required DalDataProviderChangedResponse changedResponse}) {
    DalMetaData? metaData = dataBooks[changedResponse.dataProvider]?.metaData;

    if (metaData == null) {
      return false;
    }

    return metaData.applyMetaDataFromChangedResponse(changedResponse);
  }

  @override
  DataRecord? getSelectedRowData({
    required List<String>? columnNames,
    required String dataProvider,
  }) {
    DataBook dataBook = dataBooks[dataProvider]!;

    DataRecord? selectedRowColumnData = dataBook.getSelectedRecord(dataColumnNames: columnNames);

    return selectedRowColumnData;
  }

  @override
  DataChunk getDataChunk({
    required int from,
    required String dataProvider,
    int? to,
    List<String>? columnNames,
    String? pageKey,
    bool fromStart = false
  }) {
    // Get data from all requested columns
    List<ColumnDefinition> columnDefinitions = [];
    List<int> colDefIndexes = [];

    DataBook dataBook = dataBooks[dataProvider]!;

    // Get data from data book and add column definitions in correct order -
    // either same as requested or as received from server
    if (dataBook.metaData != null) {
      if (columnNames != null) {
        for (String columnName in columnNames) {
          ColumnDefinition? colDef = dataBook.metaData!.columnDefinitions.byName(columnName);

          if (colDef != null) {
            columnDefinitions.add(colDef);
          } else {
            throw Exception("Column $columnName not found in metadata of $dataProvider");
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

    Map<int, List<dynamic>> currentDataMap = pageKey != null ? (dataBook.pageRecords[pageKey] ?? HashMap()) : dataBook.records;
    int toIndex = min(to ?? currentDataMap.length, currentDataMap.length);

    for (int i = from; i < toIndex; i++) {
      var resultRow = List<dynamic>.filled(columnDefinitions.length + 1, null);
      var dataRow = currentDataMap[i]!;

      columnDefinitions.forEachIndexed((index, colDef) {
        resultRow[index] = dataRow[colDefIndexes[index]];
      });

      resultRow.last = dataRow.last;
      resultData[i] = resultRow;

      //currently, the formats are not saved per page, so we can't support it
      if (pageKey == null) {
        List<bool>? readOnlyFormat = dataBook.recordReadOnly[i];

        //use only readonly information of matching records

        if (readOnlyFormat != null) {
          resultReadOnly[i] = readOnlyFormat;
        }

        //use only formats of matching records

        RecordFormat formats;
        RecordFormat? formatsNew;
        RowFormat? rowFormat;

        for (String key in dataBook.recordFormats.keys) {
          formats = dataBook.recordFormats[key]!;

          rowFormat = formats[i];

          if (rowFormat != null) {
            formatsNew = resultRecordFormats[key];

            if (formatsNew == null) {
              formatsNew = RecordFormat();

              resultRecordFormats[key] = formatsNew;
            }

            formatsNew[i] = rowFormat;
          }
        }
      }
    }

    return DataChunk(
      data: resultData,
      //this chunk is only all fetched if it contains all records
      isAllFetched: dataBook.isAllFetched && resultData.length == currentDataMap.length,
      columnDefinitions: ColumnList(columnDefinitions),
      from: from,
      recordFormats: resultRecordFormats,
      dataReadOnly: resultReadOnly,
      fromStart: fromStart
    );
  }

  @override
  DalMetaData? getMetaData(String dataProvider) {
    return dataBooks[dataProvider]?.metaData;
  }

  @override
  bool dataBookNeedsFetch({
    required int from,
    required String dataProvider,
    int? to,
  }) {
    if (from <= -1) {
      return false;
    }

    if (!dataBooks.containsKey(dataProvider)) {
      return true;
    }

    DataBook dataBook = dataBooks[dataProvider]!;

    // If all has already been fetched, then there is no point in fetching more,
    // If not all data is fetched and to is null (all possible data is being requested), more should be fetched
    if (dataBook.isAllFetched) {
      return false;
    } else if ((to == null || to == -1)) {
      return !fetchingDataBooks.containsKey(dataProvider) || fetchingDataBooks[dataProvider] != -1;
    }

    // Check all indexes if they are present.
    for (int i = from; i < to; i++) {
      var record = dataBook.records[i];
      if (record == null) {
        return !fetchingDataBooks.containsKey(dataProvider) || to > (fetchingDataBooks[dataProvider]!);
      }
    }

    // Returns false if all needed rows are already fetched.
    return false;
  }

  @override
  bool deleteDataFromDataBook({
    required String dataProvider,
    required int? from,
    required int? to,
    required bool? deleteAll,
  }) {
    // Get data book and return false if it does not exist
    DataBook? dataBook = dataBooks[dataProvider];
    if (dataBook == null) {
      return false;
    }
    // If delete all flag is set just clear all records
    if (deleteAll == true) {
      dataBook.clearRecords();
      return true;
    }
    // Clear only records in given range
    if (from != null && to != null) {
      dataBook.deleteRecordRange(from: from, to: to);
      return true;
    }
    return false;
  }

  @override
  bool setSelectedRow({required String dataProvider, required int newSelectedRow, String? newSelectedColumn}) {
    // get data book, if null return false
    DataBook? dataBook = dataBooks[dataProvider];
    if (dataBook == null) {
      return false;
    }
    // set selected row
    dataBook.selectedRow = newSelectedRow;
    dataBook.selectedColumn = newSelectedColumn;
    return true;
  }

  @override
  void clearData(String workScreen) {
    FlutterUI.logUI.i("Clearing all data books of prefix: $workScreen");
    FlutterUI.logUI.i("Pre clearing: ${dataBooks.values}");
    dataBooks.removeWhere((key, value) => key.startsWith(workScreen, key.indexOf("/") + 1));
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
  DataBook? getDataBook(String dataProvider) {
    return dataBooks[dataProvider];
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
    if (dataBookNeedsFetch(from: 0, dataProvider: linkReference.referencedDataBook, to: -1) ||
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
  void setDataBookFetching(String dataProvider, int to) {
    fetchingDataBooks[dataProvider] = to;
  }

  @override
  void removeDataBookFetching(String dataProvider, int to) {
    if (fetchingDataBooks[dataProvider] == to) {
      fetchingDataBooks.remove(dataProvider);
    }
  }
}
