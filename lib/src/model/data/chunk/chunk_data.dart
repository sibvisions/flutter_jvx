import 'dart:collection';

import 'package:flutter_client/src/service/data/i_data_service.dart';

/// Used as return value when getting chunk data from [IDataService]
class ChunkData {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data
  final HashMap<int, List<dynamic>> data;

  /// Only true if server has no more data.
  final bool isAllFetched;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ChunkData({
    required this.data,
    required this.isAllFetched,
  });
}
