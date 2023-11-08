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

import '../../components/editor/cell_editor/referenced_cell_editor.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/data/i_data_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/parse_util.dart';
import '../command/api/delete_record_command.dart';
import '../command/api/filter_command.dart';
import '../command/api/insert_record_command.dart';
import '../command/api/select_record_command.dart';
import '../command/api/set_values_command.dart';
import '../command/data/save_fetch_data_command.dart';
import '../component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../component/editor/cell_editor/linked/reference_definition.dart';
import '../request/filter.dart';
import '../response/dal_data_provider_changed_response.dart';
import '../response/dal_fetch_response.dart';
import '../response/dal_meta_data_response.dart';
import 'column_definition.dart';
import 'filter_condition.dart';
import 'sort_definition.dart';
import 'subscriptions/data_record.dart';
import 'subscriptions/data_subscription.dart';

/// Holds all data and column definitions of a data provider
class DataBook {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The int value for readonly records in recordReadOnly.
  static const int RECORD_READONLY = 0;

  /// The int value for editable records in recordReadOnly.
  static const int RECORD_EDITABLE = 1;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Link to source of the data,
  String dataProvider;

  /// All fetched records of this databook with specific page names.
  Map<String, Map<int, List<dynamic>>> pageRecords;

  /// All fetched records of this dataBook
  Map<int, List<dynamic>> records;

  /// All fetched records of this dataBook
  Map<int, List<bool>> recordReadOnly;

  /// If this dataBook has already fetched all possible data
  bool isAllFetched;

  /// Index of currently selected Row
  int selectedRow;

  /// Contains all metadata
  DalMetaData? metaData;

  /// Contains record formats. The key is the name of the component accessing the formats.
  Map<String, RecordFormat> recordFormats = HashMap();

  /// The selected column
  String? selectedColumn;

  /// The selected root reference
  String? rootKey;

  /// The tree path
  List<int>? treePath;

  /// Referenced linked cellEditors
  List<ReferencedCellEditor> referencedCellEditors = [];

  /// Has meta data set.
  bool hasMetaData = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [DataBook]
  DataBook({
    required this.dataProvider,
    Map<int, List<dynamic>>? records,
    this.isAllFetched = false,
    this.selectedRow = -1,
    Map<String, RecordFormat>? recordFormats,
    Map<String, Map<int, List<dynamic>>>? pageRecords,
    Map<int, List<bool>>? recordReadOnly,
  })  : records = records ?? HashMap(),
        pageRecords = pageRecords ?? HashMap(),
        recordFormats = recordFormats ?? HashMap(),
        recordReadOnly = recordReadOnly ?? HashMap();

  @override
  String toString() {
    return 'DataBook{dataProvider: $dataProvider, isAllFetched: $isAllFetched, selectedRow: $selectedRow, records.length: ${records.length}, recordFormats.length: ${recordFormats.length}}';
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Saves all data from a fetchRequest
  void saveFromFetch({required SaveFetchDataCommand pCommand}) {
    var pFetchResponse = pCommand.response;

    Map<int, List> dataMap;
    String? pageKey;
    if (metaData?.masterReference == null) {
      dataMap = records;
    } else {
      if (pFetchResponse.masterRow?.isEmpty ?? true) {
        pageKey = "noMasterRow";
      } else {
        pageKey = Filter(
          columnNames: metaData!.masterReference!.columnNames,
          values: metaData!.masterReference!.columnNames
              .mapIndexed((index, referencedColumn) => pFetchResponse.masterRow![index])
              .toList(),
        ).toPageKey();
      }

      if (!pageRecords.containsKey(pageKey)) {
        pageRecords[pageKey] = HashMap();
      }

      if (pCommand.requestFilter.isNotEmpty) {
        dataMap = pageRecords[pageKey]!;
      } else {
        dataMap = records = pageRecords[pageKey]!;
      }
    }

    if (pCommand.setRootKey == true) {
      rootKey = pageKey;
    }

    // Save records
    for (int i = 0; i < pFetchResponse.records.length; i++) {
      dataMap[i + pFetchResponse.from] = pFetchResponse.records[i];
    }

    // Remove values with higher index if all records are fetched (clean old data)
    if (pCommand.response.isAllFetched) {
      dataMap.removeWhere((key, value) => key > pFetchResponse.to);
      if (pFetchResponse.records.isEmpty) {
        dataMap.remove(0);
      }
    }

    if (pCommand.requestFilter.isEmpty) {
      isAllFetched = pFetchResponse.isAllFetched;
      selectedRow = pFetchResponse.selectedRow;
      if (pFetchResponse.json.containsKey(ApiObjectProperty.selectedColumn)) {
        selectedColumn = pFetchResponse.selectedColumn;
      }
      treePath = pFetchResponse.treePath;

      if (pFetchResponse.recordFormats != null) {
        for (String key in pFetchResponse.recordFormats!.keys) {
          var newRecordFormat = pFetchResponse.recordFormats![key]!;
          var recordFormat = recordFormats[key] ??= RecordFormat();
          for (int rowIndex in pFetchResponse.recordFormats![key]!.rowFormats.keys) {
            recordFormat.rowFormats[rowIndex] = newRecordFormat.rowFormats[rowIndex]!;
          }
        }
      }

      updateSortDefinitions(pFetchResponse.sortDefinitions);

      if (pFetchResponse.recordReadOnly != null) {
        pFetchResponse.recordReadOnly!.forEachIndexed(
          (index, element) {
            List<bool> readOnlyList = element.map((e) => e == RECORD_READONLY).toList();

            // length -1 -> Last column of the values is no "column", it is the state of the row.
            for (int i = readOnlyList.length; i < (dataMap.values.first.length - 1); i++) {
              readOnlyList.add(readOnlyList.last);
            }

            recordReadOnly[pFetchResponse.from + index] = readOnlyList;
          },
        );
      }
    }

    referencedCellEditors.forEach((refCellEditor) => refCellEditor.buildDataToDisplayMap(this));

    IUiService().notifyDataChange(
      pDataProvider: dataProvider,
      pUpdatedCurrentPage: dataMap == records,
      pUpdatedPage: pageKey,
    );
  }

  /// Saves all data from a [DalDataProviderChangedResponse]
  bool saveFromChangedResponse({required DalDataProviderChangedResponse pChangedResponse}) {
    bool changed = false;
    if (pChangedResponse.json.containsKey(ApiObjectProperty.sortDefinition)) {
      changed = updateSortDefinitions(pChangedResponse.sortDefinitions);
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

      int intColIndex = metaData?.columnDefinitions.indexWhere((element) => element.name == columnName) ?? -1;
      if (intColIndex >= 0) {
        rowData[intColIndex] = columnData;
        changed = true;
      }
    }

    return changed;
  }

  /// Sets the sort definition and returns if anything changed
  bool updateSortDefinitions(List<SortDefinition>? pSortDefinitions) {
    if (metaData == null) {
      return false;
    }

    if (metaData!.sortDefinitions == null || pSortDefinitions == null) {
      bool areDifferent = metaData!.sortDefinitions != pSortDefinitions;
      metaData!.sortDefinitions = pSortDefinitions;
      return areDifferent;
    }

    bool changeDetected = metaData!.sortDefinitions!.length != pSortDefinitions.length;

    if (!changeDetected) {
      for (SortDefinition sortDefinition in pSortDefinitions) {
        if (changeDetected) {
          break;
        }

        var oldSortDefinition =
            metaData!.sortDefinitions!.firstWhereOrNull((element) => element.columnName == sortDefinition.columnName);

        changeDetected = oldSortDefinition == null || oldSortDefinition.mode != sortDefinition.mode;
      }
    }

    metaData!.sortDefinitions = pSortDefinitions;
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
    if (!records.containsKey(pRecordIndex) || metaData == null) {
      return null;
    }

    List<dynamic> selectedRecord = records[pRecordIndex]!;
    List<ColumnDefinition> definitions = metaData!.columnDefinitions;

    if (pDataColumnNames != null) {
      // Get provided column definitions
      definitions = [];
      for (String columnName in pDataColumnNames) {
        var colDef = metaData!.columnDefinitions.firstWhereOrNull((element) => element.name == columnName);
        if (colDef != null) {
          definitions.add(colDef);
        }
      }

      // Get full selected record, then only take requested columns
      List<dynamic> fullRecord = records[pRecordIndex]!;
      selectedRecord = definitions.map((e) {
        int indexOfDef = metaData!.columnDefinitions.indexOf(e);
        return fullRecord[indexOfDef];
      }).toList();
    }

    return DataRecord(
      columnDefinitions: definitions,
      index: pRecordIndex,
      values: selectedRecord,
      selectedColumn: selectedColumn,
      treePath: treePath,
    );
  }

  /// Will return all available data from the column in the provided range
  List<dynamic> getDataFromColumn({required String pColumnName, required int pFrom, int? pTo, String? pPageKey}) {
    List<dynamic> data = [];
    int indexOfColumn = metaData?.columnDefinitions.indexWhere((element) => element.name == pColumnName) ?? -1;

    Map<int, List<dynamic>> dataMap = pPageKey != null ? (pageRecords[pPageKey] ?? HashMap()) : records;
    pTo = min(pTo ?? dataMap.length, dataMap.length);
    for (int i = pFrom; i < pTo; i++) {
      var a = dataMap[i];
      if (a != null && indexOfColumn >= 0 && indexOfColumn < a.length) {
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
    pageRecords.clear();
    records.clear();
    isAllFetched = false;
  }

  /// Selects the first record which fulfills the filter.
  ///
  /// The [pRowNumber] is to shortcut the filter.
  ///  This row index will be checked against the filter if it applies, otherwise checks every row until the filter applies.
  ///
  /// A column can be optionally selected.
  static Future<void> selectRecord({
    required String pDataProvider,
    required Filter pFilter,
    int? pRowNumber,
    String? pColumn,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(SelectRecordCommand.select(
      reason: "Select record | DataBook selectRecord",
      dataProvider: pDataProvider,
      filter: pFilter,
      rowNumber: pRowNumber,
      selectedColumn: pColumn,
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  /// Deselects the currently selected record.
  static Future<void> deselectRecord({
    required String pDataProvider,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(SelectRecordCommand.deselect(
      reason: "Select record | DataBook selectRecord",
      dataProvider: pDataProvider,
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  /// Filters the data book with the provided filter.
  static Future<void> filterRecords({
    required String pDataProvider,
    Filter? pFilter,
    FilterCondition? pFilterCondition,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(FilterCommand(
      filter: pFilter,
      filterCondition: pFilterCondition,
      dataProvider: pDataProvider,
      reason: "Filter record | DataBook filterRecords",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  /// Inserts a new record into the databook.
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

  /// Updates the record with the provided values.
  ///
  /// If no filter is provided, the currently selected record will be updated.
  static Future<void> updateRecord({
    required String pDataProvider,
    required List<String> pColumnNames,
    required List<dynamic> pValues,
    Filter? pFilter,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(SetValuesCommand(
      dataProvider: pDataProvider,
      columnNames: pColumnNames,
      values: pValues,
      filter: pFilter,
      reason: "Update record | DataBook updateRecord",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  /// Deletes the record with the provided filter.
  ///
  /// If no filter is provided, the currently selected record will be deleted.
  static Future<void> deleteRecord({
    required String pDataProvider,
    Filter? pFilter,
    int? pRowIndex,
    bool asyncErrorHandling = true,
  }) {
    var future = ICommandService().sendCommand(DeleteRecordCommand(
      dataProvider: pDataProvider,
      filter: pFilter,
      rowNumber: pRowIndex,
      reason: "Delete record | DataBook deleteRecord",
    ));
    return _handleCommandFuture(future, asyncErrorHandling);
  }

  static Future<T> _handleCommandFuture<T>(Future<T> future, bool asyncErrorHandling) {
    if (asyncErrorHandling) {
      return future.catchError((error, stackTrace) => IUiService().handleAsyncError(error, stackTrace));
    }
    return future;
  }

  static void subscribeToDataBook({
    required Object pSubObject,
    required String pDataProvider,
    List<String>? pDataColumns,
    int pFrom = -1,
    int? pTo,
    OnDataChunkCallback? pOnDataChunk,
    OnMetaDataCallback? pOnMetaData,
    OnSelectedRecordCallback? pOnSelectedRecord,
    OnDataToDisplayMapChanged? pOnDataToDisplayMapChanged,
    OnReloadCallback? pOnReload,
    OnPageCallback? pOnPage,
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
      onReload: pOnReload,
      onDataToDisplayMapChanged: pOnDataToDisplayMapChanged,
      onPage: pOnPage,
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

  /// The master reference of this databook.
  ReferenceDefinition? masterReference;

  /// The detail reference of this databook.
  ReferenceDefinition? detailReference;

  /// The root reference of this databook.
  ReferenceDefinition? rootReference;

  /// All column definitions in this dataBook
  List<ColumnDefinition> columnDefinitions = [];

  /// The name of the data provider
  String dataProvider;

  /// All visible columns of this this dataBook if shown in a table
  List<String> columnViewTable = [];

  /// All visible columns of this this dataBook if shown in a tree
  List<String> columnViewTree = [];

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

  /// The sort definitions of this databook.
  List<SortDefinition>? sortDefinitions;

  /// Combined json of this metaData
  Map<String, dynamic> json = {};

  /// The last changed properties
  List<String> changedProperties = [];

  /// The list of all created referenced cell editors.
  List<ReferencedCellEditor> createdReferencedCellEditors = [];

  /// If the row 0 is an additional row (Not deletable)
  bool additionalRowVisible = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalMetaData(this.dataProvider);

  DalMetaData.fromJson(Map<String, dynamic> pJson)
      : masterReference = pJson[ApiObjectProperty.masterReference] != null
            ? ReferenceDefinition.fromJson(pJson[ApiObjectProperty.masterReference])
            : null,
        detailReference = pJson[ApiObjectProperty.detailReference] != null
            ? ReferenceDefinition.fromJson(pJson[ApiObjectProperty.detailReference])
            : null,
        rootReference = pJson[ApiObjectProperty.rootReference] != null
            ? ReferenceDefinition.fromJson(pJson[ApiObjectProperty.rootReference])
            : null,
        dataProvider = pJson[ApiObjectProperty.dataProvider],
        columnViewTable = pJson[ApiObjectProperty.columnViewTable]?.cast<String>(),
        columnViewTree = pJson[ApiObjectProperty.columnViewTree]?.cast<String>(),
        columnDefinitions =
            (pJson[ApiObjectProperty.columns] as List<dynamic>?)?.map((e) => ColumnDefinition.fromJson(e)).toList() ??
                [],
        readOnly = pJson[ApiObjectProperty.readOnly],
        deleteEnabled = pJson[ApiObjectProperty.deleteEnabled],
        updateEnabled = pJson[ApiObjectProperty.updateEnabled],
        insertEnabled = pJson[ApiObjectProperty.insertEnabled],
        primaryKeyColumns = pJson[ApiObjectProperty.primaryKeyColumns]?.cast<String>(),
        additionalRowVisible = pJson[ApiObjectProperty.additionalRowVisible],
        json = pJson["json"] ?? {} {
    changedProperties = json.keys.toList();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyMetaDataResponse(DalMetaDataResponse pResponse) {
    changedProperties = pResponse.json.keys.toList();
    if (pResponse.columnViewTable != null) {
      columnViewTable = pResponse.columnViewTable!;
    }
    if (pResponse.columnViewTree != null) {
      columnViewTree = pResponse.columnViewTree!;
    }
    if (pResponse.masterReference != null) {
      masterReference = pResponse.masterReference!;
    }
    if (pResponse.detailReference != null) {
      detailReference = pResponse.detailReference!;
    }
    if (pResponse.rootReference != null) {
      rootReference = pResponse.rootReference!;
    }
    if (pResponse.columns != null) {
      columnDefinitions = pResponse.columns!;
      createdReferencedCellEditors.forEach((element) => element.dispose());
      columnDefinitions.forEach((colDef) {
        if (colDef.cellEditorModel is FlLinkedCellEditorModel) {
          createdReferencedCellEditors.add(IDataService().createReferencedCellEditors(
              colDef.cellEditorModel as FlLinkedCellEditorModel, dataProvider, colDef.name));
        }
      });
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
    if (pResponse.additionalRowVisible != null) {
      additionalRowVisible = pResponse.additionalRowVisible!;
    }
    ParseUtil.applyJsonToJson(pResponse.json, json);
  }

  /// Returns true if the given databook is self-joined (references itself in masterReference), false if it isn't
  bool isSelfJoined() {
    return masterReference != null && masterReference!.referencedDataBook == dataProvider;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[ApiObjectProperty.masterReference] = masterReference?.toJson();
    data[ApiObjectProperty.detailReference] = detailReference?.toJson();
    data[ApiObjectProperty.rootReference] = rootReference?.toJson();
    data[ApiObjectProperty.columns] =
        columnDefinitions.isNotEmpty ? columnDefinitions.map((e) => e.toJson()).toList() : null;
    data[ApiObjectProperty.dataProvider] = dataProvider;
    data[ApiObjectProperty.columnViewTable] = columnViewTable;
    data[ApiObjectProperty.columnViewTree] = columnViewTree;
    data[ApiObjectProperty.readOnly] = readOnly;
    data[ApiObjectProperty.deleteEnabled] = deleteEnabled;
    data[ApiObjectProperty.updateEnabled] = updateEnabled;
    data[ApiObjectProperty.insertEnabled] = insertEnabled;
    data[ApiObjectProperty.primaryKeyColumns] = primaryKeyColumns;
    data[ApiObjectProperty.additionalRowVisible] = additionalRowVisible;
    data["json"] = json;
    return data;
  }
}
