import '../../response/dal_meta_data_response.dart';
import 'data_command.dart';

/// Command to save a [DalMetaDataResponse]
class SaveMetaDataCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Metadata sent from server
  final DalMetaDataResponse response;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveMetaDataCommand({
    required this.response,
    required super.reason,
  });

  @override
  String toString() {
    return "SaveMetaDataCommand{response: $response, ${super.toString()}}";
  }
}
