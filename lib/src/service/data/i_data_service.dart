import 'package:flutter_client/src/model/data/data_book.dart';

import '../../model/api/response/dal_fetch_response.dart';
import '../../model/api/response/dal_meta_data_response.dart';
import '../../model/command/base_command.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';

/// Interface for a dataService meant to handle all dataBook related tasks,
abstract class IDataService {
  /// Establishes the meta data of the given dataBook
  Future<bool> updateMetaData({required DalMetaDataResponse pMetaData});

  /// Updates dataBook with fetched data,
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch});

  /// Returns column data of the selected row of the dataProvider
  Future<DataRecord?> getSelectedRowData({
    required List<String>? pColumnNames,
    required String pDataProvider,
  });

  /// Returns [DataChunk],
  /// if [pColumnNames] is null will return all columns
  /// if [pTo] is null will return all rows
  Future<DataChunk> getDataChunk({
    required int pFrom,
    required String pDataProvider,
    int? pTo,
    List<String>? pColumnNames,
  });

  /// Returns the full [DalMetaDataResponse] for this dataProvider
  Future<DalMetaDataResponse> getMetaData({required String pDataProvider});

  /// Returns true if a fetch for the provided range is possible/necessary to fulfill requested range.
  Future<bool> checkIfFetchPossible({
    required String pDataProvider,
    required int pFrom,
    int? pTo,
  });

  /// Returns true when deletion was successful
  Future<bool> deleteDataFromDataBook({
    required String pDataProvider,
    required int? pFrom,
    required int? pTo,
    required bool? pDeleteAll,
  });

  /// Returns true when row selection was successful (dataProvider and dataRow exist)
  Future<bool> setSelectedRow({
    required String pDataProvider,
    required int pNewSelectedRow,
  });

  /// Returns true when row selection was successful (dataProvider and dataRow exist)
  Future<bool> deleteRow({
    required String pDataProvider,
    required int pDeletedRow,
    required int pNewSelectedRow,
  });

  /// Clears all the databooks
  void clearData();

  /// Gets all databooks
  List<DataBook> getDataBooks();
}
