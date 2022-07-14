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
    required String reason,
    required this.dataProvider,
    required this.subId,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "GetDataChunkCommand: dataProvider: $dataProvider, subId: $subId, reason: $reason";
}
