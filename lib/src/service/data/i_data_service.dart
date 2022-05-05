import '../../model/api/response/dal_fetch_response.dart';
import '../../model/api/response/dal_meta_data_response.dart';
import '../../model/command/base_command.dart';
import '../../model/data/chunk/chunk_data.dart';
import '../../model/data/column_definition.dart';

/// Interface for a dataService meant to handle all dataBook related tasks,
abstract class IDataService {
  /// Establishes the meta data of the given dataBook
  Future<bool> updateMetaData({required DalMetaDataResponse pMetaData});

  /// Updates dataBook with fetched data,
  Future<List<BaseCommand>> updateData({required DalFetchResponse pFetch});

  /// DataProviderChange
  Future<List<BaseCommand>> dataProviderChange();

  /// Returns column data of the selected row of the dataProvider
  Future<dynamic> getSelectedDataColumn({required String pColumnName, required String pDataProvider});

  /// Returns a chunk of data
  Future<ChunkData> getDataChunk({required List<String> pColumnNames, required int pFrom, required int pTo, required String pDataProvider});

  /// Returns the columnDefinition of the provided column in the dataBook
  Future<ColumnDefinition> getSelectedColumnDefinition({required String pColumnName, required String pDataProvider});

  /// Returns true if a fetch for the provided range is possible/necessary to fulfill requested range.
  Future<bool> checkIfFetchPossible({
    required int pFrom,
    required int pTo,
    required String pDataProvider,
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
}
