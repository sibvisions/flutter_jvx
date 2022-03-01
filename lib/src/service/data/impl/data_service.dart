import 'dart:collection';

import 'package:flutter_client/src/model/data/column_definition.dart';

import '../../../model/data/data_book.dart';

import '../../../model/api/response/dal_fetch_response.dart';
import '../../../model/api/response/dal_meta_data_response.dart';
import '../../../model/command/base_command.dart';
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
  void updateMetaData({required DalMetaDataResponse pMetaData}) async {
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
  }

  @override
  Future<List<BaseCommand>> dataProviderChange() {
    // TODO: implement dataProviderChange
    throw UnimplementedError();
  }

  @override
  Future getSelectedDataColumn({required String pColumnName, required String pDataProvider}) async {
    // Get dataBook
    DataBook dataBook = dataBooks[pDataProvider]!;

    dynamic selectedRowColumnData = dataBook.getSelectedColumnData(pDataColumnName: pColumnName);

    return selectedRowColumnData;
  }

  @override
  Future<ColumnDefinition> getSelectedColumnDefinition({required String pColumnName, required String pDataProvider}) async {
    DataBook dataBook = dataBooks[pDataProvider]!;

    ColumnDefinition? columnDefinition = dataBook.columnDefinitions.firstWhere((element) => element.name == pColumnName);

    return columnDefinition;
  }

  @override
  Future<List<List<dynamic>>> getDataChunk(
      {required List<String> pColumnNames, required int pFrom, required int pTo, required String pDataProvider}) async {
    // TODO: implement getDataChunk

    return [];
  }
}
