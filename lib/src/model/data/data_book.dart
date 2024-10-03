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
import '../../util/column_list.dart';
import '../../util/parse_util.dart';
import '../../util/sort_list.dart';
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
import '../response/dal_meta_data_response.dart';
import '../response/record_format.dart';
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

  /// All fetched records of this data book with specific page names.
  Map<String, Map<int, List<dynamic>>> pageRecords;

  /// All fetched records of this data book
  Map<int, List<dynamic>> records;

  /// All fetched records of this data book
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

  /// Updates all data from a fetch request
  void updateFromFetch({required SaveFetchDataCommand pCommand}) {
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
        dataMap = records;
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

    if (pCommand.requestFilter.isEmpty && pageKey != null) {
      if (pCommand.response.isAllFetched) {
        pageRecords[pageKey] = dataMap;
      } else {
        for (int i = 0; i < pFetchResponse.records.length; i++) {
          pageRecords[pageKey]![i + pFetchResponse.from] = pFetchResponse.records[i];
        }
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

  /// Updates all data from a [DalDataProviderChangedResponse]
  bool updateDataChanged({required DalDataProviderChangedResponse pChangedResponse}) {
    bool changed = false;

    if (pChangedResponse.json.containsKey(ApiObjectProperty.sortDefinition)) {
      changed = updateSortDefinitions(pChangedResponse.sortDefinitions);
    }

    if (pChangedResponse.recordReadOnly != null) {
      pChangedResponse.recordReadOnly!.forEachIndexed(
        (index, element) {
          List<bool> readOnlyList = element.map((e) => e == RECORD_READONLY).toList();

          // length -1 -> Last column of the values is no "column", it is the state of the row.
          for (int i = readOnlyList.length; i < (records.values.first.length - 1); i++) {
            readOnlyList.add(readOnlyList.last);
          }

          recordReadOnly[index] = readOnlyList;
        },
      );
      changed = true;
    }

    if (pChangedResponse.recordFormats != null) {
      for (String key in pChangedResponse.recordFormats!.keys) {
        var newRecordFormat = pChangedResponse.recordFormats![key]!;
        var recordFormat = recordFormats[key] ??= RecordFormat();
        for (int rowIndex in pChangedResponse.recordFormats![key]!.rowFormats.keys) {
          recordFormat.rowFormats[rowIndex] = newRecordFormat.rowFormats[rowIndex]!;
        }
      }
      changed = true;
    }

    if (pChangedResponse.deletedRow != null && pChangedResponse.deletedRow! < records.length) {
      for (int i = pChangedResponse.deletedRow!; i < records.length - 1; i++) {
        records[i] = records[i + 1]!;
      }
      records.remove(records.length - 1);
      changed = true;
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

      int intColIndex = metaData?.columnDefinitions.indexByName(columnName) ?? -1;
      if (intColIndex >= 0) {
        rowData[intColIndex] = columnData;
        changed = true;
      }
    }

    return changed;
  }

  /// Sets the sort definition and returns if anything changed
  bool updateSortDefinitions(SortList? pSortDefinitions) {
    if (metaData == null) {
      return false;
    }

    bool changeDetected = false;

    if (metaData!.sortDefinitions == null || pSortDefinitions == null) {
      changeDetected = metaData!.sortDefinitions != pSortDefinitions;
    }

    if (pSortDefinitions != null && !changeDetected) {
      changeDetected = metaData!.sortDefinitions!.length != pSortDefinitions.length;

      if (!changeDetected) {

        for (SortDefinition sortDefinition in pSortDefinitions) {
          if (changeDetected) {
            break;
          }

          var oldSortDefinition = metaData!.sortDefinitions!.byName(sortDefinition.columnName);

          changeDetected = oldSortDefinition == null || oldSortDefinition.mode != sortDefinition.mode;
        }
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

    ColumnList? columnList;

    List<dynamic> selectedRecord = records[pRecordIndex]!;

    List<dynamic>? recordForColumnNames;

    if (pDataColumnNames != null) {
      columnList = ColumnList.empty();

      recordForColumnNames = [];

      for (String columnName in pDataColumnNames) {
        var colDef = metaData!.columnDefinitions.byName(columnName);

        if (colDef != null) {
          columnList.add(colDef);

          // We use only requested columns for our new record
          recordForColumnNames.add(selectedRecord[metaData!.columnDefinitions.indexOf(colDef)]);
        }
      }

      //add status info
      recordForColumnNames.add(selectedRecord.last);
    }

    return DataRecord(
      columnDefinitions: columnList ?? metaData!.columnDefinitions,
      index: pRecordIndex,
      values: recordForColumnNames ?? selectedRecord,
      selectedColumn: selectedColumn,
      treePath: treePath,
    );
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
  static Future<bool> selectRecord({
    required String pDataProvider,
    required Filter pFilter,
    int? pRowNumber,
    String? pColumn,
    bool showDialogOnError = true,
  }) {
    return ICommandService().sendCommand(
      SelectRecordCommand.select(
        reason: "Select record | DataBook selectRecord",
        dataProvider: pDataProvider,
        filter: pFilter,
        rowNumber: pRowNumber,
        selectedColumn: pColumn,
      ),
      showDialogOnError: showDialogOnError,
    );
  }

  /// Deselects the currently selected record.
  static Future<bool> deselectRecord({
    required String pDataProvider,
    bool showDialogOnError = true,
  }) {
    return ICommandService().sendCommand(
      SelectRecordCommand.deselect(
        reason: "Select record | DataBook selectRecord",
        dataProvider: pDataProvider,
      ),
      showDialogOnError: showDialogOnError,
    );
  }

  /// Filters the data book with the provided filter.
  static Future<bool> filterRecords({
    required String pDataProvider,
    Filter? pFilter,
    FilterCondition? pFilterCondition,
    bool showDialogOnError = true,
  }) {
    return ICommandService().sendCommand(
      FilterCommand(
        filter: pFilter,
        filterCondition: pFilterCondition,
        dataProvider: pDataProvider,
        reason: "Filter record | DataBook filterRecords",
      ),
      showDialogOnError: showDialogOnError,
    );
  }

  /// Inserts a new record into the data book.
  static Future<bool> insertRecord({
    required String pDataProvider,
    bool showDialogOnError = true,
  }) {
    return ICommandService().sendCommand(
      InsertRecordCommand(
        dataProvider: pDataProvider,
        reason: "Insert record | DataBook insertRecord",
      ),
      showDialogOnError: showDialogOnError,
    );
  }

  /// Updates the record with the provided values.
  ///
  /// If no filter is provided, the currently selected record will be updated.
  static Future<bool> updateRecord({
    required String pDataProvider,
    required List<String> pColumnNames,
    required List<dynamic> pValues,
    Filter? pFilter,
    bool showDialogOnError = true,
  }) {
    return ICommandService().sendCommand(
      SetValuesCommand(
        dataProvider: pDataProvider,
        columnNames: pColumnNames,
        values: pValues,
        filter: pFilter,
        reason: "Update record | DataBook updateRecord",
      ),
      showDialogOnError: showDialogOnError,
    );
  }

  /// Deletes the record with the provided filter.
  ///
  /// If no filter is provided, the currently selected record will be deleted.
  static Future<bool> deleteRecord({
    required String pDataProvider,
    Filter? pFilter,
    int? pRowIndex,
    bool showDialogOnError = true,
  }) {
    return ICommandService().sendCommand(
      DeleteRecordCommand(
        dataProvider: pDataProvider,
        filter: pFilter,
        rowNumber: pRowIndex,
        reason: "Delete record | DataBook deleteRecord",
      ),
      showDialogOnError: showDialogOnError,
    );
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
}

class DalMetaData {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The master reference of this data book.
  ReferenceDefinition? masterReference;

  /// The detail references of this data book.
  List<ReferenceDefinition>? detailReferences;

  /// The root reference of this data book.
  ReferenceDefinition? rootReference;

  /// All column definitions in this data book
  ColumnList columnDefinitions = ColumnList.empty();

  /// The name of the data provider
  String dataProvider;

  /// All visible columns of this this dataBook if shown in a table
  List<String> columnViewTable = [];

  /// All visible columns of this this dataBook if shown in a tree
  List<String> columnViewTree = [];

  /// If the data book is readonly.
  bool readOnly = false;

  /// If data book allows deletion of the current row.
  bool deleteEnabled = true;

  /// If data book allows deletion of any row.
  bool modelDeleteEnabled = true;

  /// If data book allows update of the current row.
  bool updateEnabled = true;

  /// If data book allows update of any row.
  bool modelUpdateEnabled = true;

  /// If data book allows insertion of the current row.
  bool insertEnabled = true;

  /// If data book allows insertion of any row.
  bool modelInsertEnabled = true;

  /// The primary key columns of the dataBook
  List<String> primaryKeyColumns = [];

  /// The sort definitions of this data book.
  SortList? sortDefinitions = SortList.empty();

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
      : dataProvider = pJson[ApiObjectProperty.dataProvider],
        columnViewTable = pJson[ApiObjectProperty.columnViewTable]?.cast<String>(),
        columnViewTree = pJson[ApiObjectProperty.columnViewTree]?.cast<String>(),
        columnDefinitions = ColumnList((pJson[ApiObjectProperty.columns] as List<dynamic>?)?.map((e) => ColumnDefinition.fromJson(e)).toList() ?? []),
        readOnly = pJson[ApiObjectProperty.readOnly],
        deleteEnabled = pJson[ApiObjectProperty.deleteEnabled],
        updateEnabled = pJson[ApiObjectProperty.updateEnabled],
        insertEnabled = pJson[ApiObjectProperty.insertEnabled],
        modelDeleteEnabled = pJson[ApiObjectProperty.modelDeleteEnabled],
        modelUpdateEnabled = pJson[ApiObjectProperty.modelUpdateEnabled],
        modelInsertEnabled = pJson[ApiObjectProperty.modelInsertEnabled],
        primaryKeyColumns = pJson[ApiObjectProperty.primaryKeyColumns]?.cast<String>(),
        masterReference = pJson[ApiObjectProperty.masterReference] != null
            ? ReferenceDefinition.fromJson(pJson[ApiObjectProperty.masterReference])
            : null,
        detailReferences = (pJson[ApiObjectProperty.detailReferences] as List<dynamic>?)?.map((e) => ReferenceDefinition.fromJson(e)).toList(),
        rootReference = pJson[ApiObjectProperty.rootReference] != null
            ? ReferenceDefinition.fromJson(pJson[ApiObjectProperty.rootReference])
            : null,
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
    if (pResponse.columnDefinitions != null) {
      columnDefinitions = pResponse.columnDefinitions!;

      createdReferencedCellEditors.forEach((element) => element.dispose());
      columnDefinitions.forEach((colDef) {
        if (colDef.cellEditorModel is FlLinkedCellEditorModel) {
          createdReferencedCellEditors.add(IDataService().createReferencedCellEditors(
              colDef.cellEditorModel as FlLinkedCellEditorModel, dataProvider, colDef.name));
        }
      });
    }
    if (pResponse.readOnly != null) {
      readOnly = pResponse.readOnly!;
    }
    if (pResponse.deleteEnabled != null) {
      deleteEnabled = pResponse.deleteEnabled!;
    }
    if (pResponse.updateEnabled != null) {
      updateEnabled = pResponse.updateEnabled!;
    }
    if (pResponse.insertEnabled != null) {
      insertEnabled = pResponse.insertEnabled!;
    }
    if (pResponse.modelDeleteEnabled != null) {
      modelDeleteEnabled = pResponse.modelDeleteEnabled!;
    }
    if (pResponse.modelUpdateEnabled != null) {
      modelUpdateEnabled = pResponse.modelUpdateEnabled!;
    }
    if (pResponse.modelInsertEnabled != null) {
      modelInsertEnabled = pResponse.modelInsertEnabled!;
    }
    if (pResponse.primaryKeyColumns != null) {
      primaryKeyColumns = pResponse.primaryKeyColumns!;
    }
    if (pResponse.masterReference != null) {
      masterReference = pResponse.masterReference!;
    }
    if (pResponse.detailReferences != null) {
      detailReferences = pResponse.detailReferences!;
    }
    if (pResponse.rootReference != null) {
      rootReference = pResponse.rootReference!;
    }
    if (pResponse.additionalRowVisible != null) {
      additionalRowVisible = pResponse.additionalRowVisible!;
    }
    ParseUtil.applyJsonToJson(pResponse.json, json);
  }

  /// Returns true if the given data book is self-joined (references itself in masterReference), false if it isn't
  bool isSelfJoined() {
    return masterReference != null && masterReference!.referencedDataBook == dataProvider;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[ApiObjectProperty.dataProvider] = dataProvider;
    data[ApiObjectProperty.columnViewTable] = columnViewTable;
    data[ApiObjectProperty.columnViewTree] = columnViewTree;
    data[ApiObjectProperty.columns] = columnDefinitions.isNotEmpty ? columnDefinitions.map((e) => e.toJson()).toList() : null;
    data[ApiObjectProperty.readOnly] = readOnly;
    data[ApiObjectProperty.deleteEnabled] = deleteEnabled;
    data[ApiObjectProperty.updateEnabled] = updateEnabled;
    data[ApiObjectProperty.insertEnabled] = insertEnabled;
    data[ApiObjectProperty.modelDeleteEnabled] = modelDeleteEnabled;
    data[ApiObjectProperty.modelUpdateEnabled] = modelUpdateEnabled;
    data[ApiObjectProperty.modelInsertEnabled] = modelInsertEnabled;
    data[ApiObjectProperty.primaryKeyColumns] = primaryKeyColumns;
    data[ApiObjectProperty.masterReference] = masterReference?.toJson();
    data[ApiObjectProperty.detailReferences] = (detailReferences != null && detailReferences!.isNotEmpty) ? detailReferences!.map((e) => e.toJson()).toList() : null;
    data[ApiObjectProperty.rootReference] = rootReference?.toJson();
    data[ApiObjectProperty.additionalRowVisible] = additionalRowVisible;
    data["json"] = json;
    return data;
  }

}
