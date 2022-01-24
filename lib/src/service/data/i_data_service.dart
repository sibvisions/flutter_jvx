import 'package:flutter_client/src/model/api/response/dal_fetch_response.dart';
import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';

/// Interface for a dataService meant to handle all dataBook related tasks,
/// this class is intended to be used as an interface
abstract class IDataService {

  /// Establishes the meta data of the given dataBook
  void updateMetaData({required DalMetaDataResponse pMetaData});

  /// Updates dataBook with fetched data,
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch});

  /// DataProviderChange
  Future<List<BaseCommand>> dataProviderChange();
}