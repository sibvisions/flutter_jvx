import 'dart:collection';

import '../../service/command/i_command_service.dart';
import '../../service/service.dart';
import '../../service/ui/i_ui_service.dart';
import '../command/api/delete_record_command.dart';
import '../command/api/filter_command.dart';
import '../command/api/insert_record_command.dart';
import '../command/api/select_record_command.dart';
import '../command/api/set_values_command.dart';
import '../request/filter.dart';
import '../response/dal_fetch_response.dart';
import '../response/dal_meta_data_response.dart';
import 'column_definition.dart';
import 'filter_condition.dart';
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

  /// List of column names which should be shown if this dataBook is to be
  List<String> columnViewTable;

  /// Definitions for all columns of this dataBook
  List<ColumnDefinition> columnDefinitions;

  /// All fetched records of this dataBook
  HashMap<int, List<dynamic>> records;

  /// If this dataBook has already fetched all possible data
  bool isAllFetched;

  /// Index of currently selected Row
  int selectedRow;

  /// Contains all metadata
  DalMetaDataResponse? metaData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [DataBook]
  DataBook({
    required this.dataProvider,
    required this.records,
    required this.columnDefinitions,
    required this.isAllFetched,
    required this.selectedRow,
    required this.columnViewTable,
    this.metaData,
  });

  /// Creates a [DataBook] with only default values
  DataBook.empty()
      : dataProvider = "",
        columnViewTable = [],
        columnDefinitions = [],
        records = HashMap(),
        selectedRow = -1,
        isAllFetched = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Saves all data from a fetchRequest
  void saveFromFetchRequest({required DalFetchResponse pFetchResponse}) {
    dataProvider = pFetchResponse.dataProvider;
    isAllFetched = pFetchResponse.isAllFetched;
    selectedRow = pFetchResponse.selectedRow;

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

  /// Get the selected record,
  /// If no record is currently selected (-1) returns null
  /// If selected row is not found returns null
  DataRecord? getSelectedRecord({required List<String>? pDataColumnNames}) {
    //TODO inspect incorrect calls
    return getRecord(pDataColumnNames: pDataColumnNames, pRecordIndex: selectedRow);
  }

  /// Gets a record
  /// If row is not found returns null
  DataRecord? getRecord({required List<String>? pDataColumnNames, required int pRecordIndex}) {
    if (!records.containsKey(pRecordIndex)) {
      return null;
    }

    List<dynamic> selectedRecord = records[pRecordIndex]!;
    List<ColumnDefinition> definitions = columnDefinitions;

    if (pDataColumnNames != null) {
      // Get provided column definitions
      definitions = [];
      for (String columnName in pDataColumnNames) {
        definitions.add(columnDefinitions.firstWhere((element) => element.name == columnName));
      }

      // Get full selected record, then only take requested columns
      List<dynamic> fullRecord = records[pRecordIndex]!;
      selectedRecord = definitions.map((e) {
        int indexOfDef = columnDefinitions.indexOf(e);
        return fullRecord[indexOfDef];
      }).toList();
    }

    return DataRecord(
      columnDefinitions: definitions,
      index: pRecordIndex,
      values: selectedRecord,
    );
  }

  /// Will return all available data from the column in the provided range
  List<dynamic> getDataFromColumn({required String pColumnName, required int pFrom, required int pTo}) {
    List<dynamic> data = [];
    int indexOfColumn = columnDefinitions.indexWhere((element) => element.name == pColumnName);

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
    var future = services<ICommandService>().sendCommand(SelectRecordCommand(
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
    var future = services<ICommandService>().sendCommand(FilterCommand(
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
    var future = services<ICommandService>().sendCommand(InsertRecordCommand(
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
    var future = services<ICommandService>().sendCommand(SetValuesCommand(
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
    var future = services<ICommandService>().sendCommand(DeleteRecordCommand(
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
        services<IUiService>().handleAsyncError(error, stackTrace);
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
    void Function(DalMetaDataResponse)? pOnMetaData,
    void Function(DataRecord?)? pOnSelectedRecord,
  }) {
    IUiService uiService = services<IUiService>();
    uiService.registerDataSubscription(
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
    IUiService uiService = services<IUiService>();
    uiService.disposeDataSubscription(pSubscriber: pSubObject, pDataProvider: pDataProvider);
  }

  static int getColumnIndex(List<ColumnDefinition> columnDefinitions, String columnName) {
    return columnDefinitions.indexWhere((colDef) => colDef.name == columnName);
  }
}
