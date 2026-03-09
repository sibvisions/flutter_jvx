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
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../components/editor/cell_editor/referenced_cell_editor.dart';
import '../../flutter_ui.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/config/shared/config_handler.dart';
import '../../service/data/i_data_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/column_list.dart';
import '../../util/crypto_util.dart';
import '../../util/i_types.dart';
import '../../util/parse_util.dart';
import '../../util/sort_list.dart';
import '../command/api/delete_record_command.dart';
import '../command/api/filter_command.dart';
import '../command/api/insert_record_command.dart';
import '../command/api/select_record_command.dart';
import '../command/api/set_values_command.dart';
import '../command/data/save_fetch_data_command.dart';
import '../component/editor/cell_editor/cell_editor_model.dart';
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
  Map<String, Map<int, List<dynamic>>> pageRecords = HashMap();

  /// All fetched records of this data book
  Map<int, List<dynamic>> records = HashMap();

  /// All fetched records of this data book
  Map<int, List<bool>> recordReadOnly = HashMap();

  /// All crypto locks
  final Map<String?, Map<int, List<String>>> _cryptoLock = HashMap();

  /// If this dataBook has already fetched all possible data
  bool isAllFetched = false;

  /// Index of currently selected Row
  int selectedRow = -1;

  /// Contains all metadata
  DalMetaData? _metaData;

  /// Meta data access
  DalMetaData? get metaData => _metaData;

  /// Sets meta data
  set metaData(DalMetaData? value) {
    bool noMetaData  = _metaData == null;

    _metaData = value;

    //if we set metadata for first time -> update values
    if (noMetaData && value != null) {
      _decryptCachedValues();
    }
  }

  /// The list of still decrypted records because of missing metadata
  Map<String?, List<int>>? _notDecryptedCache;

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

  /// current token for encryption
  String? token;

  /// Has meta data set.
  bool hasMetaData = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [DataBook]
  DataBook({
    required this.dataProvider,
    DalMetaData? metaData
  }) : _metaData = metaData,
       hasMetaData = metaData != null;

  @override
  String toString() {
    return "DataBook{dataProvider: $dataProvider, isAllFetched: $isAllFetched, selectedRow: $selectedRow, "
           "records.length: ${records.length}, recordFormats.length: ${recordFormats.length}, "
           "hasMetaData: $hasMetaData, token set: ${token != null}}";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Updates all data from a fetch request
  Future<void> updateFromFetch({required SaveFetchDataCommand pCommand}) async {
    var pFetchResponse = pCommand.response;

    Map<int, List<dynamic>> dataMap;
    String? pageKey;

    bool newPageKey = false;

    if (_metaData?.masterReference == null) {
      dataMap = records;
    } else {
      if (pFetchResponse.masterRow?.isEmpty ?? true) {
        pageKey = "noMasterRow";
      } else {
        pageKey = Filter(
          columnNames: _metaData!.masterReference!.columnNames,
          values: _metaData!.masterReference!.columnNames
              .mapIndexed((index, referencedColumn) => pFetchResponse.masterRow![index])
              .toList(),
        ).toPageKey();
      }

      if (!pageRecords.containsKey(pageKey)) {
        pageRecords[pageKey] = HashMap();
        newPageKey = true;
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

    List<int>? notDecrypted;

    if (_metaData == null) {
      notDecrypted = [];
    }

    // Save records
    for (int i = 0; i < pFetchResponse.records.length; i++) {
      if (notDecrypted != null) {
        notDecrypted.add(pFetchResponse.from + i);
      }

      dataMap[pFetchResponse.from + i] = await _decryptValues(pageKey, pFetchResponse.from + i, pFetchResponse.records[i], _metaData!);
    }

    if (notDecrypted != null) {
      _notDecryptedCache ??= {};
      _notDecryptedCache![pageKey] = notDecrypted;
    }

    // Remove values with higher index if all records are fetched (clean old data)
    if (pCommand.response.isAllFetched == true) {
      if (pFetchResponse.records.isEmpty) {
        dataMap.clear();

        _notDecryptedCache = null;
        _cryptoLock.clear();
      }
      else {
        dataMap.removeWhere((key, value) => key > pFetchResponse.to);
      }
    }

    if (pCommand.requestFilter.isEmpty && pageKey != null) {
      if (pCommand.response.isAllFetched == true) {
        pageRecords[pageKey] = dataMap;
      } else {
        for (int i = 0; i < pFetchResponse.records.length; i++) {
          pageRecords[pageKey]![pFetchResponse.from + i] = dataMap[pFetchResponse.from + i]!;
        }
      }
    }

    if (pCommand.requestFilter.isEmpty) {
      //don't change if isAllFetched is missing
      if (pFetchResponse.isAllFetched != null) {
        isAllFetched = pFetchResponse.isAllFetched!;
      }

      selectedRow = pFetchResponse.selectedRow;
      if (pFetchResponse.json.containsKey(ApiObjectProperty.selectedColumn)) {
        selectedColumn = pFetchResponse.selectedColumn;
      }
      treePath = pFetchResponse.treePath;

      _updateSortDefinitions(pFetchResponse.sortDefinitions);
      _updateRecordReadOnly(pFetchResponse.recordReadOnly, dataMap, pFetchResponse.from);
      _updateRecordFormats(pFetchResponse.recordFormats);
    }

    referencedCellEditors.forEach((refCellEditor) => refCellEditor.buildDataToDisplayMap(this));

    IUiService().notifyDataChange(
      pDataProvider: dataProvider,
      pUpdatedCurrentPage: dataMap == records,
      pUpdatedPage: pageKey,
      pFromStart: pFetchResponse.clear || newPageKey || (pFetchResponse.from == 0 && (pFetchResponse.to > 0 || pFetchResponse.isAllFetched == true))
    );
  }

  /// Updates record readonly. This method takes retrieved read-only mappings and converts from int to bool with full column
  /// count and not the minimized mapping
  bool _updateRecordReadOnly(List<List<dynamic>>? readOnlyMapping, Map<int, List<dynamic>> records, int startIndex) {
    if (readOnlyMapping == null) {
      return false;
    }

    // length -1 -> Last column of the values is no "column", it is the state of the row.
    int columnCount = records.values.first.length - 1;

    List<dynamic> mappingEntry;

    bool changed = false;

    for (int i = 0; i < readOnlyMapping.length; i++) {
      mappingEntry = readOnlyMapping[i];

      //filled
      List<bool> readOnlyList = List.filled(columnCount, mappingEntry.last == RECORD_READONLY);

      if (mappingEntry.length > 1) {
        //Translate values to bool
        for (int j = 0; j < mappingEntry.length; j++) {
          readOnlyList[j] = mappingEntry[j] == RECORD_READONLY;
        }
      }

      List<bool>? oldReadOnlyList = recordReadOnly[startIndex + i];

      if (!changed) {
        //check if mapping has changed
        changed |= !listEquals(oldReadOnlyList, readOnlyList);
      }

      recordReadOnly[startIndex + i] = readOnlyList;
    }

    return changed;
  }

  /// Updates record formats.
  bool _updateRecordFormats(Map<String, RecordFormat>? formats) {
    if (formats == null) {
      return false;
    }

    bool changed = false;

    for (String key in formats.keys) {
      var newRecordFormat = formats[key]!;
      var recordFormat = recordFormats[key];

      if (recordFormat == null) {
        recordFormat = RecordFormat();

        changed = true;
      }

      RowFormat? oldRowFormat;

      for (int rowIndex in recordFormats[key]!.keys) {
        if (!changed) {
          oldRowFormat = recordFormat[rowIndex];

          if (oldRowFormat == null) {
            changed = true;
          }
          else {
            changed |= oldRowFormat == newRecordFormat[rowIndex]!;
          }
        }

        recordFormat[rowIndex] = newRecordFormat[rowIndex]!;
      }
    }

    return changed;
  }

  /// Updates all data from a [DalDataProviderChangedResponse]
  bool updateDataChanged({required DalDataProviderChangedResponse pChangedResponse}) {
    bool changed = _updateSortDefinitions(pChangedResponse.sortDefinitions);
    changed |= _updateRecordReadOnly(pChangedResponse.recordReadOnly, records, 0);
    changed |= _updateRecordFormats(pChangedResponse.recordFormats);

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

      int colIndex = _metaData?.columnDefinitions.indexByName(columnName) ?? -1;
      if (colIndex >= 0) {
        if (_metaData?.columnDefinitions[colIndex].dataTypeIdentifier == Types.ENCODED_BINARY) {
          columnData = decryptValue(columnData);
        }

        rowData[colIndex] = columnData;
        changed = true;
      }
    }

    return changed;
  }

  /// Sets the sort definition and returns if anything changed
  bool _updateSortDefinitions(SortList? pSortDefinitions) {
    if (_metaData == null) {
      return false;
    }

    bool changeDetected = false;

    if (_metaData!.sortDefinitions == null || pSortDefinitions == null) {
      changeDetected = _metaData!.sortDefinitions != pSortDefinitions;
    }

    if (pSortDefinitions != null && !changeDetected) {
      changeDetected = _metaData!.sortDefinitions!.length != pSortDefinitions.length;

      if (!changeDetected) {

        for (SortDefinition sortDefinition in pSortDefinitions) {
          if (changeDetected) {
            break;
          }

          var oldSortDefinition = _metaData!.sortDefinitions!.byName(sortDefinition.columnName);

          changeDetected = oldSortDefinition == null || oldSortDefinition.mode != sortDefinition.mode;
        }
      }
    }

    _metaData!.sortDefinitions = pSortDefinitions;

    return changeDetected;
  }

  bool hasCryptoLock(int rowNumber, String columnName) {
    return _cryptoLock[null]?[rowNumber]?.contains(columnName) ?? false;
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
    if (!records.containsKey(pRecordIndex) || _metaData == null) {
      return null;
    }

    ColumnList? columnList;

    List<dynamic> selectedRecord = records[pRecordIndex]!;

    List<dynamic>? recordForColumnNames;

    if (pDataColumnNames != null) {
      columnList = ColumnList.empty();

      recordForColumnNames = [];

      for (String columnName in pDataColumnNames) {
        var colDef = _metaData!.columnDefinitions.byName(columnName);

        if (colDef != null) {
          columnList.add(colDef);

          // We use only requested columns for our new record
          recordForColumnNames.add(selectedRecord[_metaData!.columnDefinitions.indexOf(colDef)]);
        }
      }

      //add status info
      recordForColumnNames.add(selectedRecord.last);
    }

    return DataRecord(
      columnDefinitions: columnList ?? _metaData!.columnDefinitions,
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
    token = null;

    pageRecords.clear();
    records.clear();

    _cryptoLock.clear();
    _notDecryptedCache = null;

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

  /// Encrypts [values] of [columnNames] if necessary.
  Future<List<dynamic>?> encryptValues(List<String> columnNames, List<dynamic> values) async {
    List<dynamic>? valuesEncrypted;

    if (metaData != null) {
      ColumnDefinition? colDef;

      for (int i = 0; i < columnNames.length; i++) {
        colDef = metaData!.columnDefinitions.byName(columnNames[i]);

        if (colDef?.dataTypeIdentifier == Types.ENCODED_BINARY) {
          valuesEncrypted ??= List.from(values);

          valuesEncrypted[i] = await _encryptValue(valuesEncrypted[i]);
        }
        else if (colDef?.dataTypeIdentifier == Types.BINARY) {
          if (values[i] != null
              && values[i] is! Uint8List
              && !CryptoUtil.isBase64(values[i])) {
            String valueString = values[i].toString();

            if (valueString.isNotEmpty) {
              valuesEncrypted ??= List.from(values);

              valuesEncrypted[i] = base64Encode(utf8.encode(valueString));
            }
          }
        }
      }
    }

    return valuesEncrypted;
  }

  /// Encrypts [value].
  dynamic _encryptValue(dynamic value) async {
    if (value == null || (value is String && value.isEmpty)) {
      return value;
    }

    ConfigHandler cfgHandler = IConfigService().getConfigHandler();

    if (token == null) {
      token = await cfgHandler.getValueSecure("${await cfgHandler.currentApp()}.encToken");

      if (token == null) {
        try {
          token ??= await IUiService().getInput("Encryption token", "Token", true);

          if (token != null && token!.isNotEmpty) {
            await cfgHandler.setValueSecure("${await cfgHandler.currentApp()}.encToken", token);
          }
        }
        catch (e) {
          FlutterUI.logUI.e(e);
        }
      }
    }

    if (token != null && token!.isNotEmpty) {
      return CryptoUtil.encrypt(value, token!);
    }
    else if (value is! Uint8List
             && !CryptoUtil.isBase64(value))
    {
      return base64Encode(utf8.encode(value.toString()));
    }

    return value;
  }

  Future<List<dynamic>> _decryptValues(String? pageKey, int rowNumber, List<dynamic> record, DalMetaData? metaData) async {
    if (metaData == null) {
      return record;
    }

    List<dynamic>? newRecord;

    ColumnList colList = metaData.columnDefinitions;

    DecryptedValue decValue;

    for (int i = 0; i < colList.length; i++) {
      if (colList[i].dataTypeIdentifier == Types.ENCODED_BINARY) {
        newRecord ??= List.from(record);
        decValue = await decryptValue(newRecord[i]);

        if (decValue.type == CryptoValueType.DecryptFailure
            || decValue.type == CryptoValueType.Encrypted) {
          Map<int, List<String>>? locks = _cryptoLock[pageKey];

          if (locks == null) {
            locks = HashMap();
            _cryptoLock[pageKey] = locks;
          }

          List<String>? rowLocks = locks[rowNumber];

          if (rowLocks == null) {
            rowLocks = List.filled(3, colList[i].name, growable: true);

            locks[rowNumber] = rowLocks;
          }
          else if (!rowLocks.contains(colList[i].name)) {
            rowLocks.add(colList[i].name);
          }
        }
        else {
          _cryptoLock[pageKey]?[rowNumber]?.remove(colList[i].name);

          newRecord[i] = decValue.value;
        }
      }
      else if (colList[i].dataTypeIdentifier == Types.BINARY) {
        //converts a string to binary
        if (record[i] is String) {
          newRecord ??= List.from(record);

          Uint8List? newValue = CryptoUtil.tryDecodeBase64(newRecord[i]);

          if (newValue != null) {
            newRecord[i] = newValue;
          }
        }
      }
    }

    return newRecord ?? record;
  }

  Future<DecryptedValue> decryptValue(dynamic value) async {
    if (value == null) {
      return DecryptedValue(value: value, type: CryptoValueType.PlainText);
    }

    ConfigHandler cfgHandler = IConfigService().getConfigHandler();

    if (token == null) {
      token = await cfgHandler.getValueSecure("${await cfgHandler.currentApp()}.encToken");

      if (token == null) {
        try {
          token ??= await IUiService().getInput("Encryption token", "Token", true);

          if (token != null && token!.isNotEmpty) {
            await cfgHandler.setValueSecure("${await cfgHandler.currentApp()}.encToken", token);
          }
        }
        catch (e) {
          FlutterUI.logUI.e(e);
        }
      }
    }

    dynamic encodedValue = value;

    Uint8List? base64Decoded = CryptoUtil.tryDecodeBase64(value);

    if (base64Decoded != null) {
      try {
        encodedValue = utf8.decode(base64Decoded);
      }
      catch (ex) {
        FlutterUI.log.d(ex);
      }
    }

    if (token != null && token!.isNotEmpty) {
      return CryptoUtil.decrypt(encodedValue, token!);
    }
    else if (CryptoUtil.maybeEncrypted(encodedValue)) {

      return DecryptedValue(value: value, type: CryptoValueType.Encrypted);
    }

    return DecryptedValue(value: encodedValue ?? value, type: CryptoValueType.PlainText);
  }

  Future<void> _decryptCachedValues() async {
    if (_notDecryptedCache != null) {
      Map<int, List<dynamic>>? allRecords;

      for (final entry in _notDecryptedCache!.entries) {
        if (entry.key == null) {
          allRecords = records;
        }
        else {
          allRecords = pageRecords[entry.key];
        }

        if (allRecords != null) {
          List<dynamic>? record;

          for (int i = 0; i < entry.value.length; i++) {
            record = allRecords[i];

            if (record != null) {
              record[i] = await _decryptValues(entry.key, i, record, metaData);
            }
          }
        }
      }

      _notDecryptedCache = null;
    }
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

  DalMetaData([String? dataProvider]) : dataProvider = dataProvider ?? "";

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

  bool applyMetaDataResponse(DalMetaDataResponse pResponse) {
    changedProperties = pResponse.json.keys.toList();

    bool isChanged = false;

    DeepCollectionEquality comp = const DeepCollectionEquality.unordered();

    if (pResponse.columnViewTable != null && !comp.equals(columnViewTable, pResponse.columnViewTable)) {
      columnViewTable = pResponse.columnViewTable!;

      isChanged = true;
    }
    if (pResponse.columnViewTree != null && !comp.equals(columnViewTree, pResponse.columnViewTree)) {
      columnViewTree = pResponse.columnViewTree!;

      isChanged = true;
    }
    if (pResponse.columnDefinitions != null) {
      createdReferencedCellEditors.forEach((element) => element.dispose());
      createdReferencedCellEditors.clear();

      columnDefinitions = pResponse.columnDefinitions!;
      columnDefinitions.forEach((colDef) {
        if (colDef.cellEditorModel is FlLinkedCellEditorModel) {
          createdReferencedCellEditors.add(IDataService().createReferencedCellEditors(
              colDef.cellEditorModel as FlLinkedCellEditorModel, dataProvider, colDef.name));
        }
      });

      isChanged = true;
    }
    if (pResponse.readOnly != null && readOnly != pResponse.readOnly) {
      readOnly = pResponse.readOnly!;

      isChanged = true;
    }
    if (pResponse.deleteEnabled != null && deleteEnabled != pResponse.deleteEnabled) {
      deleteEnabled = pResponse.deleteEnabled!;

      isChanged = true;
    }
    if (pResponse.updateEnabled != null && updateEnabled != pResponse.updateEnabled) {
      updateEnabled = pResponse.updateEnabled!;

      isChanged = true;
    }
    if (pResponse.insertEnabled != null && insertEnabled != pResponse.insertEnabled) {
      insertEnabled = pResponse.insertEnabled!;

      isChanged = true;
    }
    if (pResponse.modelDeleteEnabled != null && modelDeleteEnabled != pResponse.modelDeleteEnabled) {
      modelDeleteEnabled = pResponse.modelDeleteEnabled!;

      isChanged = true;
    }
    if (pResponse.modelUpdateEnabled != null && modelUpdateEnabled != pResponse.modelUpdateEnabled) {
      modelUpdateEnabled = pResponse.modelUpdateEnabled!;

      isChanged = true;
    }
    if (pResponse.modelInsertEnabled != null && modelInsertEnabled != pResponse.modelInsertEnabled) {
      modelInsertEnabled = pResponse.modelInsertEnabled!;

      isChanged = true;
    }
    if (pResponse.primaryKeyColumns != null && !comp.equals(primaryKeyColumns, pResponse.primaryKeyColumns)) {
      primaryKeyColumns = pResponse.primaryKeyColumns!;

      isChanged = true;
    }
    if (pResponse.masterReference != null) {
      masterReference = pResponse.masterReference!;

      isChanged = true;
    }
    if (pResponse.detailReferences != null) {
      detailReferences = pResponse.detailReferences!;

      isChanged = true;
    }
    if (pResponse.rootReference != null) {
      rootReference = pResponse.rootReference!;

      isChanged = true;
    }
    if (pResponse.additionalRowVisible != null && additionalRowVisible != pResponse.additionalRowVisible) {
      additionalRowVisible = pResponse.additionalRowVisible!;

      isChanged = true;
    }

    isChanged |= ParseUtil.applyJsonToJson(pResponse.json, json);

    return isChanged;
  }

  bool applyMetaDataFromChangedResponse(DalDataProviderChangedResponse pResponse) {
    changedProperties.clear();

    if (pResponse.readOnly != null && readOnly != pResponse.readOnly) {
      readOnly = pResponse.readOnly!;

      changedProperties.add(ApiObjectProperty.readOnly);
    }

    if (pResponse.insertEnabled != null && insertEnabled != pResponse.insertEnabled) {
      insertEnabled = pResponse.insertEnabled!;

      changedProperties.add(ApiObjectProperty.insertEnabled);
    }

    if (pResponse.updateEnabled != null && updateEnabled != pResponse.updateEnabled) {
      updateEnabled = pResponse.updateEnabled!;

      changedProperties.add(ApiObjectProperty.updateEnabled);
    }

    if (pResponse.deleteEnabled != null && deleteEnabled != pResponse.deleteEnabled) {
      deleteEnabled = pResponse.deleteEnabled!;

      changedProperties.add(ApiObjectProperty.deleteEnabled);
    }

    if (pResponse.modelInsertEnabled != null && modelInsertEnabled != pResponse.modelInsertEnabled) {
      modelInsertEnabled = pResponse.modelInsertEnabled!;

      changedProperties.add(ApiObjectProperty.modelInsertEnabled);
    }

    if (pResponse.modelUpdateEnabled != null && modelUpdateEnabled != pResponse.modelUpdateEnabled) {
      modelUpdateEnabled = pResponse.modelUpdateEnabled!;

      changedProperties.add(ApiObjectProperty.modelUpdateEnabled);
    }

    if (pResponse.modelDeleteEnabled != null && modelDeleteEnabled != pResponse.modelDeleteEnabled) {
      modelDeleteEnabled = pResponse.modelDeleteEnabled!;

      changedProperties.add(ApiObjectProperty.modelDeleteEnabled);
    }

    if (pResponse.additionalRowVisible != null && additionalRowVisible != pResponse.additionalRowVisible!) {
      additionalRowVisible = pResponse.additionalRowVisible!;

      changedProperties.add(ApiObjectProperty.additionalRowVisible);
    }

    if (pResponse.changedColumns != null) {

      bool isColumnChanged = false;

      pResponse.changedColumns!.forEach((changedColumn) {

        ColumnDefinition? foundColumn = columnDefinitions.byName(changedColumn.name);

        if (foundColumn != null) {
          if (changedColumn.label != null && changedColumn.label != foundColumn.label) {
            foundColumn.label = changedColumn.label!;

            isColumnChanged |= true;
          }

          if (changedColumn.readOnly != null && changedColumn.readOnly != foundColumn.readOnly) {
            foundColumn.readOnly = changedColumn.readOnly!;

            isColumnChanged |= true;
          }

          if (changedColumn.movable != null && changedColumn.movable != foundColumn.movable) {
            foundColumn.movable = changedColumn.movable!;

            isColumnChanged |= true;
          }

          if (changedColumn.sortable != null && changedColumn.sortable != foundColumn.sortable) {
            foundColumn.sortable = changedColumn.sortable!;

            isColumnChanged |= true;
          }

          if (changedColumn.cellEditorJson != null) {
            for (int i = createdReferencedCellEditors.length - 1; i >= 0; i--) {
              if (createdReferencedCellEditors[i].columnName == foundColumn.name) {
                createdReferencedCellEditors[i].dispose();
                createdReferencedCellEditors.removeAt(i);
              }
            }

            foundColumn.cellEditorJson = changedColumn.cellEditorJson!;
            foundColumn.cellEditorModel = ICellEditorModel.fromJson(foundColumn.cellEditorJson);

            if (foundColumn.cellEditorModel is FlLinkedCellEditorModel) {
              createdReferencedCellEditors.add(IDataService().createReferencedCellEditors(
                  foundColumn.cellEditorModel as FlLinkedCellEditorModel,
                  pResponse.dataProvider,
                  foundColumn.name));
            }

            isColumnChanged |= true;
          }
        }
      });

      if (isColumnChanged) {
        changedProperties.add(ApiObjectProperty.columns);
      }
    }

    return changedProperties.isNotEmpty;
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
