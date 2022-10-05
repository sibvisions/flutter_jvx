import '../../data/subscriptions/data_subscription.dart';
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
    required this.dataProvider,
    this.columnNames,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "GetSelectedDataCommand{dataProvider: $dataProvider, subId: $subId, columnNames: $columnNames, ${super.toString()}}";
  }
}
