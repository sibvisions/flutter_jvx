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

import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';

import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/parse_util.dart';
import '../command/api/delete_record_command.dart';
import '../command/api/filter_command.dart';
import '../command/api/insert_record_command.dart';
import '../command/api/select_record_command.dart';
import '../command/api/set_values_command.dart';
import '../request/filter.dart';
import '../response/dal_data_provider_changed_response.dart';
import '../response/dal_fetch_response.dart';
import '../response/dal_meta_data_response.dart';
import 'column_definition.dart';
import 'filter_condition.dart';
import 'sort_definition.dart';
import 'subscriptions/data_chunk.dart';
import 'subscriptions/data_record.dart';
import 'subscriptions/data_subscription.dart';

/// Holds all data and column definitions of a data provider
class DataBook {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Link to source of the data,
  String dataProvider;

  /// All fetched records of this dataBook
  HashMap<int, List<dynamic>> records;

  /// If this dataBook has already fetched all possible data
  bool isAllFetched;

  /// Index of currently selected Row
  int selectedRow;

  /// Contains all metadata
  DalMetaData metaData;

  /// Contains record formats
  Map<String, RecordFormat>? recordFormats;

  /// The sort definitions of this databook.
  List<SortDefinition>? sortDefinitions;

  /// The selected column
  String? selectedColumn;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [DataBook]
  DataBook({
    required this.dataProvider,
    required this.records,
    required this.isAllFetched,
    required this.selectedRow,
    this.recordFormats,
  }) : metaData = DalMetaData(dataProvider);

  /// Creates a [DataBook] with only default values
  DataBook.empty()
      : dataProvider = "",
        records = HashMap(),
        selectedRow = -1,
        isAllFetched = false,
        metaData = DalMetaData("");

  @override
  String toString() {
    return 'DataBook{dataProvider: $dataProvider, isAllFetched: $isAllFetched, selectedRow: $selectedRow, records.length: ${records.length}, recordFormats.length: ${recordFormats?.length}}';
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Saves all data from a fetchRequest
  void saveFromFetchRequest({required DalFetchResponse pFetchResponse}) {
    dataProvider = pFetchResponse.dataProvider;
    isAllFetched = pFetchResponse.isAllFetched;
    selectedRow = pFetchResponse.selectedRow;
    if (pFetchResponse.json.containsKey(ApiObjectProperty.selectedColumn)) {
      selectedColumn = pFetchResponse.selectedColumn;
    }
    recordFormats = pFetchResponse.recordFormats;
    updateSortDefinitions(pFetchResponse.sortDefinitions);

    // Save records
    for (int i = 0; i < pFetchResponse.records.length; i++) {
      records[i + pFetchResponse.from] = pFetchResponse.records[i];
    }

    // Remove values with higher index if all records are fetched (clean old data)
    if (isAllFetched) {
      records.removeWhere((key, value) => key > pFetchResponse.to);
      if (pFetchResponse.records.isEmpty) {
        records.remove(0);
      }
    }
  }

  /// Saves all data from a [DalDataProviderChangedResponse]
  bool saveFromChangedResponse({required DalDataProviderChangedResponse pChangedResponse}) {
    bool changed = updateSortDefinitions(pChangedResponse.sortDefinitions);

    if (pChangedResponse.json.containsKey(ApiObjectProperty.selectedColumn)) {
      changed = true;
      selectedColumn = pChangedResponse.selectedColumn;
    }

    if (pChangedResponse.json.containsKey(ApiObjectProperty.selectedRow) && pChangedResponse.selectedRow != null) {
      changed = true;
      selectedRow = pChangedResponse.selectedRow!;
    }

    if (pChangedResponse.changedColumnNames == null ||
        pChangedResponse.changedValues == null ||
        pChangedResponse.selectedRow == null) {
      return changed;
    }

    List<dynamic>? rowData = records[pChangedResponse.selectedRow!];
    if (rowData == null) {
      return changed;
    }

    for (int index = 0;
        index < min(pChangedResponse.changedColumnNames!.length, pChangedResponse.changedValues!.length);
        index++) {
      String columnName = pChangedResponse.changedColumnNames![index];
      dynamic columnData = pChangedResponse.changedValues![index];

      int intColIndex = metaData.columnDefinitions.indexWhere((element) => element.name == columnName);
      if (intColIndex >= 0) {
        rowData[intColIndex] = columnData;
        changed = true;
      }
    }

    return changed;
  }

  /// Sets the sort definition and returns if anything changed
  bool updateSortDefinitions(List<SortDefinition>? pSortDefinitions) {
    if (sortDefinitions == null || pSortDefinitions == null) {
      bool areDifferent = sortDefinitions != pSortDefinitions;
      sortDefinitions = pSortDefinitions;
      return areDifferent;
    }

    bool changeDetected = sortDefinitions!.length != pSortDefinitions.length;

    if (!changeDetected) {
      for (SortDefinition sortDefinition in pSortDefinitions) {
        if (changeDetected) {
          break;
        }

        var oldSortDefinition =
            sortDefinitions!.firstWhereOrNull((element) => element.columnName == sortDefinition.columnName);

        changeDetected = oldSortDefinition == null || oldSortDefinition.mode != sortDefinition.mode;
      }
    }

    sortDefinitions = pSortDefinitions;
    return changeDetected;
  }

  /// Get the selected record,
  /// If no record is currently selected (-1) returns null
  /// If selected row is not found returns null
  DataRecord? getSelectedRecord({required List<String>? pDataColumnNames}) {
    return getRecord(pDataColumnNames: pDataColumnNames, pRecordIndex: selectedRow);
  }

  /// Gets a record
  /// If row is not found returns null
  DataRecord? getRecord({required List<String>? pDataColumnNames, required int pRecordIndex}) {
    if (!records.containsKey(pRecordIndex)) {
      return null;
    }

    List<dynamic> selectedRecord = records[pRecordIndex]!;
    List<ColumnDefinition> definitions = metaData.columnDefinitions;

    if (pDataColumnNames != null) {
      // Get provided column definitions
      definitions = [];
      for (String columnName in pDataColumnNames) {
        var colDef = metaData.columnDefinitions.firstWhereOrNull((element) => element.name == columnName);
        if (colDef != null) {
          definitions.add(colDef);
        }
      }

      // Get full selected record, then only take requested columns
      List<dynamic> fullRecord = records[pRecordIndex]!;
      selectedRecord = definitions.map((e) {
        int indexOfDef = metaData.columnDefinitions.indexOf(e);
        return fullRecord[indexOfDef];
      }).toList();
    }

    return DataRecord(
      columnDefinitions: definitions,
      index: pRecordIndex,
      values: selectedRecord,
      selectedColumn: selectedColumn,
    );
  }

  /// Will return all available data from the column in the provided range
  List<dynamic> getDataFromColumn({required String pColumnName, required int pFrom, required int pTo}) {
    List<dynamic> data = [];
    int indexOfColumn = metaData.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    for (int i = pFrom; i < pTo; i++) {
      var a = records[i];
      if (a != null) {
        data.add(a[indexOfColumn]);
      }
    }
    return data;
  }

  /// Deletes all records in the specified range, even when they do not exist
  void deleteRecordRange({required int pFrom, required int pTo}) {
    for (int i = pFrom; pFrom <= pTo; i++) {
      if (records.remove(i) != null) {
        isAllFetched = false;
        if (selectedRow == i) {
          selectedRow = -1;
        }
      }
    }
  }

  /// Deletes all current records
  void clearRecords() {
    records.clear();
    isAllFetched = false;
    selectedRow = -1;
  }

  static Future<void> selectRecord({
    required String pDataProvider,
    required int pSelectedRecord,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(SelectRecordCommand(
      reason: "Select record | DataBook selectRecord",
      dataProvider: pDataProvider,
      selectedRecord: pSelectedRecord,
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  static Future<void> filterRecords({
    required String pDataProvider,
    Filter? pFilter,
    FilterCondition? pFilterCondition,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(FilterCommand(
      editorId: "custom",
      filter: pFilter,
      filterCondition: pFilterCondition,
      dataProvider: pDataProvider,
      reason: "Filter record | DataBook filterRecords",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  static Future<void> insertRecord({
    required String pDataProvider,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(InsertRecordCommand(
      dataProvider: pDataProvider,
      reason: "Insert record | DataBook insertRecord",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  static Future<void> updateRecord({
    required String pDataProvider,
    required List<String> pColumnNames,
    required List<dynamic> pValues,
    Filter? pFilter,
    FilterCondition? pFilterCondition,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(SetValuesCommand(
      componentId: "custom",
      dataProvider: pDataProvider,
      columnNames: pColumnNames,
      values: pValues,
      filter: pFilter,
      filterCondition: pFilterCondition,
      reason: "Update record | DataBook updateRecord",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  static Future<void> deleteRecord({
    required String pDataProvider,
    Filter? pFilter,
    FilterCondition? pFilterCondition,
    int? pRowIndex,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(DeleteRecordCommand(
      dataProvider: pDataProvider,
      filter: pFilter,
      filterCondition: pFilterCondition,
      selectedRow: pRowIndex,
      reason: "Delete record | DataBook deleteRecord",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  static Future<T> _handleCommandFuture<T>(Future<T> future, bool asyncErrorHandling) {
    if (asyncErrorHandling) {
      return future.catchError((error, stackTrace) {
        IUiService().handleAsyncError(error, stackTrace);
      });
    }
    return future;
  }

  static void subscribeToDataBook({
    required Object pSubObject,
    required String pDataProvider,
    List<String>? pDataColumns,
    int pFrom = -1,
    int? pTo,
    void Function(DataChunk)? pOnDataChunk,
    void Function(DalMetaData)? pOnMetaData,
    void Function(DataRecord?)? pOnSelectedRecord,
  }) {
    IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
      subbedObj: pSubObject,
      dataProvider: pDataProvider,
      dataColumns: pDataColumns,
      from: pFrom,
      to: pTo,
      onDataChunk: pOnDataChunk,
      onMetaData: pOnMetaData,
      onSelectedRecord: pOnSelectedRecord,
    ));
  }

  static void unsubscribeToDataBook({
    required Object pSubObject,
    String? pDataProvider,
  }) {
    IUiService().disposeDataSubscription(pSubscriber: pSubObject, pDataProvider: pDataProvider);
  }

  static int getColumnIndex(List<ColumnDefinition> columnDefinitions, String columnName) {
    return columnDefinitions.indexWhere((colDef) => colDef.name == columnName);
  }
}

class DalMetaData {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// All column definitions in this dataBook
  List<ColumnDefinition> columnDefinitions = [];

  /// The name of the data provider
  String dataProvider;

  /// All visible columns of this this dataBook if shown in a table
  List<String> columnViewTable = [];

  /// If the databook is readonly.
  bool readOnly = false;

  /// If deletion is allowed.
  bool deleteEnabled = true;

  /// If updating a row is allowed.
  bool updateEnabled = true;

  /// If inserting a row is allowed.
  bool insertEnabled = true;

  /// The primary key columns of the dataBook
  List<String> primaryKeyColumns = [];

  /// Combined json of this metaData
  Map<String, dynamic> json = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalMetaData(this.dataProvider);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyMetaDataResponse(DalMetaDataResponse pResponse) {
    if (pResponse.columnViewTable != null) {
      columnViewTable = pResponse.columnViewTable!;
    }
    if (pResponse.columns != null) {
      columnDefinitions = pResponse.columns!;
    }
    if (pResponse.primaryKeyColumns != null) {
      primaryKeyColumns = pResponse.primaryKeyColumns!;
    }
    if (pResponse.deleteEnabled != null) {
      deleteEnabled = pResponse.deleteEnabled!;
    }
    if (pResponse.insertEnabled != null) {
      insertEnabled = pResponse.insertEnabled!;
    }
    if (pResponse.readOnly != null) {
      readOnly = pResponse.readOnly!;
    }
    if (pResponse.updateEnabled != null) {
      updateEnabled = pResponse.updateEnabled!;
    }
    ParseUtil.applyJsonToJson(json, pResponse.json);
  }
}
