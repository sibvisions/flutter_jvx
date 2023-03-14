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

import 'package:collection/collection.dart';

import '../../../flutter_ui.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/save_fetch_data_command.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/data/data_book.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/response/dal_data_provider_changed_response.dart';
import '../../../model/response/dal_meta_data_response.dart';
import '../../api/shared/api_object_property.dart';
import '../../api/shared/fl_component_classname.dart';
import '../i_data_service.dart';

class DataService implements IDataService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all DataBooks with dataProvider as key
  HashMap<String, DataBook> dataBooks = HashMap();

  /// Map of all currently fetching databooks with dataProvider as key and value is the row to fetch to.
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
  FutureOr<void> clear(bool pFullClear) {
    clearDataBooks();
  }

  @override
  List<BaseCommand> updateData({required SaveFetchDataCommand pCommand}) {
    DataBook? dataBook = dataBooks[pCommand.response.dataProvider] ?? DataBook.empty();
    dataBooks[pCommand.response.dataProvider] = dataBook;

    if (pCommand.response.clear) {
      dataBook.clearRecords();
      dataBook.selectedRow = -1;
    }

    dataBook.saveFromFetch(pCommand: pCommand);

    return [];
  }

  @override
  bool updateDataChangedResponse({required DalDataProviderChangedResponse pChangedResponse}) {
    DataBook? dataBook = dataBooks[pChangedResponse.dataProvider];
    if (dataBook == null) {
      return false;
    }

    return dataBook.saveFromChangedResponse(pChangedResponse: pChangedResponse);
  }

  @override
  bool updateSelectionChangedResponse({required DalDataProviderChangedResponse pChangedResponse}) {
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

    dataBook.metaData.applyMetaDataResponse(pChangedResponse);

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

    pMetaData.columnDefinitions
        .forEach((colDef) => IDataService().createReferencedCellEditors(colDef, pMetaData.dataProvider));

    return true;
  }

  @override
  bool updateMetaDataChangedRepsonse({required DalDataProviderChangedResponse pChangedResponse}) {
    DataBook? dataBook = dataBooks[pChangedResponse.dataProvider];
    DalMetaData? metaData = dataBook?.metaData;
    if (metaData == null) {
      return false;
    }

    bool anyChanges = false;
    if (pChangedResponse.insertEnabled != null && metaData.insertEnabled != pChangedResponse.insertEnabled) {
      metaData.insertEnabled = pChangedResponse.insertEnabled!;
      anyChanges = true;
    }
    if (pChangedResponse.updateEnabled != null && metaData.updateEnabled != pChangedResponse.updateEnabled) {
      metaData.updateEnabled = pChangedResponse.updateEnabled!;
      anyChanges = true;
    }

    if (pChangedResponse.deleteEnabled != null && metaData.deleteEnabled != pChangedResponse.deleteEnabled) {
      metaData.deleteEnabled = pChangedResponse.deleteEnabled!;
      anyChanges = true;
    }

    if (pChangedResponse.readOnly != null && metaData.readOnly != pChangedResponse.readOnly) {
      metaData.readOnly = pChangedResponse.readOnly!;
      anyChanges = true;
    }

    if (pChangedResponse.changedColumns != null) {
      pChangedResponse.changedColumns!.forEach((changedColumn) {
        ColumnDefinition? foundColumn =
            metaData.columnDefinitions.firstWhereOrNull((element) => element.name == changedColumn.name);
        if (foundColumn != null) {
          if (changedColumn.label != null && changedColumn.label != foundColumn.label) {
            foundColumn.label = changedColumn.label!;
            anyChanges = true;
          }
          if (changedColumn.readOnly != null && changedColumn.readOnly != foundColumn.readOnly) {
            foundColumn.readOnly = changedColumn.readOnly!;
            anyChanges = true;
          }
          if (changedColumn.movable != null && changedColumn.movable != foundColumn.movable) {
            foundColumn.movable = changedColumn.movable!;
            anyChanges = true;
          }
          if (changedColumn.sortable != null && changedColumn.sortable != foundColumn.sortable) {
            foundColumn.sortable = changedColumn.sortable!;
            anyChanges = true;
          }
          if (changedColumn.cellEditorJson != null) {
            foundColumn.cellEditorJson = changedColumn.cellEditorJson!;
            foundColumn.cellEditorModel = ICellEditorModel.fromJson(foundColumn.cellEditorJson);
            IDataService().createReferencedCellEditors(foundColumn, pChangedResponse.dataProvider);
            anyChanges = true;
          }
        }
      });
    }

    return anyChanges;
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
  }) {
    // Get data from all requested columns
    List<List<dynamic>> columnsData = [];
    List<ColumnDefinition> columnDefinitions = [];

    DataBook dataBook = dataBooks[pDataProvider]!;

    // If pTo is null, all possible records are being requested
    pTo ??= dataBook.records.length;

    // Get data from databook and add column definitions in correct order -
    // either same as requested or as received from server
    if (pColumnNames != null) {
      for (String columnName in pColumnNames) {
        columnDefinitions.add(dataBook.metaData.columnDefinitions.firstWhere((element) => element.name == columnName));
        columnsData.add(dataBook.getDataFromColumn(
          pColumnName: columnName,
          pFrom: pFrom,
          pTo: pTo,
          pPageKey: pPageKey,
        ));
      }
    } else {
      columnDefinitions.addAll(dataBook.metaData.columnDefinitions);

      for (ColumnDefinition colDef in columnDefinitions) {
        columnsData.add(dataBook.getDataFromColumn(
          pColumnName: colDef.name,
          pFrom: pFrom,
          pTo: pTo,
          pPageKey: pPageKey,
        ));
      }
    }

    // Check if requested range of fetch is too long
    int rowCount = columnsData.firstOrNull?.length ?? 0;

    // Build rows out of column data
    HashMap<int, List<dynamic>> data = HashMap();
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      List<dynamic> row = [];
      for (List column in columnsData) {
        row.add(column[rowIndex]);
      }
      data[rowIndex + pFrom] = row;
    }

    return DataChunk(
      data: data,
      isAllFetched: dataBook.isAllFetched,
      columnDefinitions: columnDefinitions,
      from: pFrom,
      to: pTo,
      recordFormats: dataBook.recordFormats,
    );
  }

  @override
  DalMetaData getMetaData({required String pDataProvider}) {
    DataBook dataBook = dataBooks[pDataProvider]!;
    return dataBook.metaData;
  }

  @override
  bool databookNeedsFetch({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
  }) {
    if (!dataBooks.containsKey(pDataProvider)) {
      return true;
    }

    DataBook dataBook = dataBooks[pDataProvider]!;

    // If all has already been fetched, then there is no point in fetching more,
    // If not all data is fetched and pTo is null (all possible data is being requested), more should be fetched
    if (dataBook.isAllFetched) {
      return false;
    } else if ((pTo == null || pTo == -1)) {
      return fetchingDataBooks[pDataProvider] != -1;
    }

    // Check all indexes if they are present.
    for (int i = pFrom; i < pTo; i++) {
      var record = dataBook.records[i];
      if (record == null) {
        return fetchingDataBooks[pDataProvider] == null || pTo > (fetchingDataBooks[pDataProvider]!);
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
    // get databook, if null return false
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
  bool deleteRow({
    required String pDataProvider,
    required int pDeletedRow,
    required int pNewSelectedRow,
  }) {
    // get databook, if null return false
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null || dataBook.records.length <= pDeletedRow) {
      return false;
    }

    for (int i = pDeletedRow; i < dataBook.records.length - 1; i++) {
      dataBook.records[i] = dataBook.records[i + 1]!;
    }

    dataBook.records.remove(dataBook.records.length - 1);

    dataBook.selectedRow = pNewSelectedRow;

    return true;
  }

  @override
  void clearData(String pWorkscreen) {
    FlutterUI.logUI.i("Clearing all data books of prefix: $pWorkscreen");
    FlutterUI.logUI.i("Pre clearing: ${dataBooks.values}");
    dataBooks.removeWhere((key, value) => key.startsWith(pWorkscreen, key.indexOf("/") + 1));
    FlutterUI.logUI.i("Post clearing: ${dataBooks.values}");
  }

  @override
  void clearDataBooks() {
    return dataBooks.clear();
  }

  @override
  HashMap<String, DataBook> getDataBooks() {
    return HashMap.from(dataBooks);
  }

  @override
  DataBook? getDataBook(String pDataProvider) {
    return dataBooks[pDataProvider];
  }

  @override
  void createReferencedCellEditors(ColumnDefinition column, String dataProvider) {
    if (column.cellEditorModel.className == FlCellEditorClassname.LINKED_CELL_EDITOR) {
      var linkReference = (column.cellEditorModel as FlLinkedCellEditorModel).linkReference;

      print("Creating referenced cell editor for column: ${column.name} + ${linkReference.hashCode}");
      DataBook referencedDataBook = dataBooks[linkReference.referencedDataprovider] ??= DataBook.empty();

      ReferencedCellEditor referencedCellEditor =
          ReferencedCellEditor(column.cellEditorModel, column.name, dataProvider);

      referencedDataBook.referencedCellEditors.removeWhere((element) => element.columnName == column.name);
      referencedDataBook.referencedCellEditors.add(referencedCellEditor);

      if (linkReference.columnNames.isEmpty && linkReference.referencedColumnNames.isNotEmpty) {
        linkReference.columnNames.add(column.name);
      }

      referencedDataBook.buildDataToDisplayMap(referencedCellEditor, referencedDataBook.records.values.toList(),
          referencedDataBook.metaData.columnDefinitions.map((e) => e.name).toList());
    }
  }

  @override
  void setDatabookFetching(String pDataProvider, int pTo) {
    fetchingDataBooks[pDataProvider] = pTo;
  }

  @override
  void removeDatabookFetching(String pDataProvider, int pTo) {
    if (fetchingDataBooks[pDataProvider] == pTo) {
      fetchingDataBooks.remove(pDataProvider);
    }
  }
}
