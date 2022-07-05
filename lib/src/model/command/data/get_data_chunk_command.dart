import 'package:flutter_client/src/model/data/subscriptions/data_subscription.dart';

import 'data_command.dart';

class GetDataChunkCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the [DataSubscription] requesting data
  final String subId;

  /// Link to the dataBook containing the data
  final String dataProvider;

  /// List of names of the dataColumns that are being requested
  final List<String>? dataColumns;

  /// From which index data is being requested
  final int from;

  /// To which index data is being requested
  final int? to;

  /// True if the the data should only overwrite old existing data
  final bool isUpdate;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GetDataChunkCommand({
    required String reason,
    required this.dataProvider,
    required this.from,
    required this.subId,
    this.isUpdate = false,
    this.to,
    this.dataColumns,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "GetDataChunkCommand: dataProvider: $dataProvider, from: $from, subId: $subId, isUpdate: $isUpdate, to: $to, dataColumns: $dataColumns,  reason: $reason";
}
