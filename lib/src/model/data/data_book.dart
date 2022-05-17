import 'dart:collection';

import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_record.dart';

import '../api/response/dal_fetch_response.dart';
import 'column_definition.dart';

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

  /// Empties the records list
  void deleteAllRecords() {
    records = HashMap();
  }

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
    }
  }

  /// Get date of of the selected record,
  /// If no record is currently selected (-1) returns null
  /// If selected row is not found returns null
  DataRecord? getSelectedRecord({required List<String>? pDataColumnNames}) {
    if (selectedRow == -1) {
      return null;
    }

    List<ColumnDefinition> definitions = columnDefinitions;
    List<dynamic> selectedRecord = records[selectedRow]!;

    if (pDataColumnNames != null) {
      // Get provided column definitions
      definitions = [];
      for (String columnName in pDataColumnNames) {
        definitions.add(columnDefinitions.firstWhere((element) => element.name == columnName));
      }

      // Get full selected record, then only take requested columns
      List<dynamic> fullRecord = records[selectedRow]!;
      selectedRecord = definitions.map((e) {
        int indexOfDef = columnDefinitions.indexOf(e);
        return fullRecord[indexOfDef];
      }).toList();
    }

    return DataRecord(
      columnDefinitions: definitions,
      index: selectedRow,
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
      records.remove(i);
    }
  }

  /// Deletes all current records
  void clearRecords() {
    records.clear();
  }
}
