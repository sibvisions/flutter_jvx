import 'dart:math';

import '../../../service/ui/i_ui_service.dart';
import '../../response/dal_meta_data_response.dart';
import 'data_chunk.dart';
import 'data_record.dart';

typedef OnSelectedRecordCallback = void Function(DataRecord? dataRecord);
typedef OnDataChunkCallback = void Function(DataChunk dataChunk);
typedef OnMetaDataCallback = void Function(DalMetaDataResponse metaData);

/// Used for subscribing in [IUiService] to potentially receive data.
class DataSubscription {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unique id of this subscription
  final String id;

  /// Reference to creator of this subscription
  final Object subbedObj;

  /// Data provider from which data will be fetched
  final String dataProvider;

  /// Callback will be called with selected row, regardless if only the selected row was fetched
  final OnSelectedRecordCallback? onSelectedRecord;

  /// Index from which data will be fetched, set to -1 to only receive the selected row
  final int from;

  /// Index to which data will be fetched, if null - will return all data from provider, will fetch if necessary
  final int? to;

  /// Callback will only be called with [DataChunk] if from is not -1.
  final OnDataChunkCallback? onDataChunk;

  /// Callback will be called with metaData of requested dataBook
  final OnMetaDataCallback? onMetaData;

  /// List of column names which should be fetched, return order will correspond to order of this list
  final List<String>? dataColumns;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataSubscription({
    required this.subbedObj,
    required this.dataProvider,
    this.from = -1,
    this.onSelectedRecord,
    this.onDataChunk,
    this.onMetaData,
    this.to,
    this.dataColumns,
  }) : id = getRandomString(15);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool same(DataSubscription subscription) {
    if (subscription.id == id && subscription.dataProvider == dataProvider) {
      return true;
    }
    return false;
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) =>
    String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
