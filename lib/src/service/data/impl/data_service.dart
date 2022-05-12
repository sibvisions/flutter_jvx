import 'dart:collection';

import '../../../model/api/response/dal_fetch_response.dart';
import '../../../model/api/response/dal_meta_data_response.dart';
import '../../../model/command/base_command.dart';
import '../../../model/data/chunk/chunk_data.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/data/data_book.dart';
import '../i_data_service.dart';

class DataService implements IDataService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all DataBooks with dataProvider as key
  HashMap<String, DataBook> dataBooks = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization",
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates an [DataService] Instance
  DataService();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch}) async {
    DataBook? dataBook = dataBooks[pFetch.dataProvider];
    if (dataBook == null) {
      dataBook = DataBook.empty();
      dataBook.saveFromFetchRequest(pFetchResponse: pFetch);
      dataBooks[pFetch.dataProvider] = dataBook;
    } else {
      dataBook.saveFromFetchRequest(pFetchResponse: pFetch);
    }

    return [];
  }

  @override
  Future<bool> updateMetaData({required DalMetaDataResponse pMetaData}) async {
    DataBook? dataBook = dataBooks[pMetaData.dataProvider];

    if (dataBook == null) {
      dataBook = DataBook(
          dataProvider: pMetaData.dataProvider,
          records: HashMap(),
          columnDefinitions: pMetaData.columns,
          isAllFetched: false,
          selectedRow: -1,
          columnViewTable: pMetaData.columnViewTable);
      dataBooks[dataBook.dataProvider] = dataBook;
    } else {
      dataBook.columnDefinitions = pMetaData.columns;
      dataBook.columnViewTable = pMetaData.columnViewTable;
    }

    return true;
  }

  @override
  Future<List<BaseCommand>> dataProviderChange() {
    // TODO: implement dataProviderChange
    throw UnimplementedError();
  }

  @override
  Future getSelectedDataColumn({required String pColumnName, required String pDataProvider}) async {
    DataBook dataBook = dataBooks[pDataProvider]!;
    dynamic selectedRowColumnData = dataBook.getSelectedColumnData(pDataColumnName: pColumnName);

    return selectedRowColumnData;
  }

  @override
  Future<ColumnDefinition> getSelectedColumnDefinition(
      {required String pColumnName, required String pDataProvider}) async {
    DataBook dataBook = dataBooks[pDataProvider]!;
    ColumnDefinition? columnDefinition =
        dataBook.columnDefinitions.firstWhere((element) => element.name == pColumnName);

    return columnDefinition;
  }

  @override
  Future<ChunkData> getDataChunk({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
    List<String>? pColumnNames,
  }) async {
    // Get data from all requested columns
    List<List<dynamic>> columnData = [];
    List<ColumnDefinition> columnDefinitions = [];

    DataBook dataBook = dataBooks[pDataProvider]!;

    // If pTo is null, all possible records are being requested
    pTo ??= dataBook.records.length;

    // Get data from databook and add column definitions in correct order -
    // either same as requested or as received from server
    if (pColumnNames != null) {
      for (String columnName in pColumnNames) {
        columnDefinitions.add(dataBook.columnDefinitions.firstWhere((element) => element.name == columnName));
        columnData.add(dataBook.getDataFromColumn(
          pColumnName: columnName,
          pFrom: pFrom,
          pTo: pTo,
        ));
      }
    } else {
      columnDefinitions.addAll(dataBook.columnDefinitions);

      for (ColumnDefinition colDef in columnDefinitions) {
        columnData.add(dataBook.getDataFromColumn(
          pColumnName: colDef.name,
          pFrom: pFrom,
          pTo: pTo,
        ));
      }
    }

    // Check if requested range of fetch is too long
    int fetchLength = pTo - pFrom;
    if (columnData[0].length < fetchLength) {
      fetchLength = columnData[0].length;
    }

    // Build rows out of column data
    HashMap<int, List<dynamic>> data = HashMap();
    for (int i = 0; i < fetchLength; i++) {
      List<dynamic> row = [];
      for (List d in columnData) {
        row.add(d[i]);
      }
      data[i + pFrom] = row;
    }

    return ChunkData(data: data, isAllFetched: dataBook.isAllFetched, columnDefinitions: columnDefinitions);
  }

  @override
  Future<bool> checkIfFetchPossible({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
  }) async {
    DataBook dataBook = dataBooks[pDataProvider]!;

    // If all has already been fetched, then there is no point in fetching more,
    // If not all data is fetched and pTo is null (all possible data is being requested), more should be fetched
    if (dataBook.isAllFetched) {
      return false;
    } else if (pTo == null) {
      return true;
    }

    // Check all indexes if they are present.
    for (int i = pFrom; i < pTo; i++) {
      var record = dataBook.records[i];
      if (record == null) {
        return true;
      }
    }

    // Returns false if all needed rows are already fetched.
    return false;
  }

  @override
  Future<bool> deleteDataFromDataBook({
    required String pDataProvider,
    required int? pFrom,
    required int? pTo,
    required bool? pDeleteAll,
  }) async {
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
  Future<bool> setSelectedRow({
    required String pDataProvider,
    required int pNewSelectedRow,
  }) async {
    // get databook, if null return false
    DataBook? dataBook = dataBooks[pDataProvider];
    if (dataBook == null) {
      return false;
    }
    // set selected row
    dataBook.selectedRow = pNewSelectedRow;
    return true;
  }
}
