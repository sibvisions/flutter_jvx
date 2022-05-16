import 'package:flutter_client/src/model/data/subscriptions/data_subscription.dart';

import 'data_command.dart';

/// Command to get data of a specific column of the selectedRow of an dataBook(dataProvider)
class GetSelectedDataCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider
  final String dataProvider;

  /// Id of the [DataSubscription]
  final String subId;

  /// Name of the column
  final List<String>? columnNames;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GetSelectedDataCommand({
    required this.subId,
    required String reason,
    required this.dataProvider,
    this.columnNames,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  // TODO: implement logString
  String get logString => "IMPLEMENT GET_DATA LOG";
}
