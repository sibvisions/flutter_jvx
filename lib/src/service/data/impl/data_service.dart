import 'dart:collection';

import '../../../model/api/response/dal_fetch_response.dart';
import '../../../model/api/response/dal_meta_data_response.dart';
import '../../../model/command/base_command.dart';
import '../../../model/data/column_definition.dart';
import '../i_data_service.dart';

class DataService implements IDataService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all DataBooks with dataProvider as key
  HashMap<String, DataBook> dataBooks = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch}) async {
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
}

/// Holds all data and column definitions of a data provider
class DataBook {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Link to source of the data,
  final String dataProvider;

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

  DataBook(
      {required this.dataProvider,
      required this.records,
      required this.columnDefinitions,
      required this.isAllFetched,
      required this.selectedRow,
      required this.columnViewTable});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Empties the records list
  void deleteAllRecords() {
    records = HashMap();
  }

  /// Saves all incoming records, overwrites records if already present
  void saveDataRecords({required List<dynamic> pRecords, required int from, required int to}) {
    while (from != to) {
      records[from] = pRecords[to - from];
      from++;
    }
  }
}
