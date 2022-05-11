import 'package:flutter_client/src/model/data/chunk/chunk_subscription.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';
import 'package:flutter_client/src/service/data/i_data_service.dart';

/// Used as return value when getting chunk data from [IDataService]
class ChunkData {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data map, key is the index of the data in the dataBook
  final Map<int, List<dynamic>> data;

  /// List of all column definitions, order is the same as the columnNames requested in [ChunkSubscription],
  /// if left empty - will contain all columns
  final List<ColumnDefinition> columnDefinitions;

  /// Only true if server has no more data.
  final bool isAllFetched;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ChunkData({
    required this.data,
    required this.isAllFetched,
    required this.columnDefinitions,
  });

  const ChunkData.empty()
      : data = const <int, List<dynamic>>{},
        isAllFetched = false,
        columnDefinitions = const [];
}
