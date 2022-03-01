import '../../model/api/response/dal_fetch_response.dart';
import '../../model/api/response/dal_meta_data_response.dart';
import '../../model/command/base_command.dart';
import '../../model/data/column_definition.dart';

/// Interface for a dataService meant to handle all dataBook related tasks,
abstract class IDataService {

  /// Establishes the meta data of the given dataBook
  void updateMetaData({required DalMetaDataResponse pMetaData});

  /// Updates dataBook with fetched data,
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch});

  /// DataProviderChange
  Future<List<BaseCommand>> dataProviderChange();

  /// Returns column data of the selected row of the dataProvider
  Future<dynamic> getSelectedDataColumn({required String pColumnName, required String pDataProvider});

  /// Returns a chunk of data with only
  Future<List<List<dynamic>>> getDataChunk({required List<String> pColumnNames, required int pFrom, required int pTo, required String pDataProvider});

  /// Returns the columnDefinition of the provided column in the dataBook
  Future<ColumnDefinition> getSelectedColumnDefinition({required String pColumnName, required String pDataProvider});
}
