import 'dart:collection';

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

  /// Saves all incoming records, overwrites records if already present
  void saveDataRecords({required List<dynamic> pRecords, required int pFrom, required int pTo}) {
    while (pFrom != pTo) {
      records[pFrom] = pRecords[pTo - pFrom];
      pFrom++;
    }
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
  }

  /// Get data of the column of the currently selected row
  /// If no record is currently selected (-1) returns null
  /// If selected row is not found returns null
  dynamic getSelectedColumnData({required String pDataColumnName}) {
    // Get index of column
    int indexOfColumn = columnDefinitions.indexWhere((columnDef) => columnDef.name == pDataColumnName);

    // If column with provided name was not found throw error.
    if (indexOfColumn == -1) {
      throw Exception("Column with name $pDataColumnName was not found in dataBook $dataProvider");
    }

    // Get record of selectedRow
    List<dynamic>? record = records[selectedRow];

    // If record is found return value at the index of the column.
    // ToDo Handle non-existing record better.
    if (record != null) {
      return record[indexOfColumn];
    } else {
      return null;
    }
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
}
