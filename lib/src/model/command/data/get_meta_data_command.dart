import '../../data/subscriptions/data_subscription.dart';
import 'data_command.dart';

class GetMetaDataCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider for which the meta data will be returned
  final String dataProvider;

  /// Id of [DataSubscription] where meta data will be returned to
  final String subId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GetMetaDataCommand({
    required this.dataProvider,
    required this.subId,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'GetMetaDataCommand{dataProvider: $dataProvider, subId: $subId, ${super.toString()}}';
  }
}
