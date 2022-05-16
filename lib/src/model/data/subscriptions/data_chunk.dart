import 'package:flutter_client/src/model/data/column_definition.dart';
import 'package:flutter_client/src/service/data/i_data_service.dart';

/// Used as return value when getting subscriptions data from [IDataService]
class DataChunk {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data map, key is the index of the data in the dataBook
  final Map<int, List<dynamic>> data;

  /// List of all column definitions, order is the same as the columnNames requested in [DataSubscription],
  /// if left empty - will contain all columns
  final List<ColumnDefinition> columnDefinitions;

  /// Only true if server has no more data.
  final bool isAllFetched;

  /// index of first record in databook
  final int from;

  /// index to which data has been fetched
  final int to;

  /// True if this chunk is only an update on already fetched data
  bool update;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataChunk({
    required this.data,
    required this.isAllFetched,
    required this.columnDefinitions,
    required this.from,
    required this.to,
    this.update = false,
  });
}
