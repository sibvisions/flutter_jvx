import 'package:flutter_client/src/service/ui/i_ui_service.dart';

/// Used for subscribing in [IUiService] to potentially receive data.
class ChunkSubscription {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the component
  final String id;

  /// Callback which will be executed with receiving data.
  final Function callback;

  /// Index from which data will be fetched
  final int from;

  /// Index to which data will be fetched
  final int to;

  /// Data provider from which data will be fetched
  final String dataProvider;

  /// List of column names which should be fetched, return order will correspond to order of this list
  final List<String> dataColumns;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ChunkSubscription({
    required this.id,
    required this.from,
    required this.dataProvider,
    required this.callback,
    required this.dataColumns,
    required this.to,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool same(ChunkSubscription subscription) {
    if (subscription.id == id && subscription.dataProvider == dataProvider) {
      return true;
    }
    return false;
  }
}
