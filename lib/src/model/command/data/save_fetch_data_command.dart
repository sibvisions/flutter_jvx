import '../../response/dal_fetch_response.dart';
import 'data_command.dart';

class SaveFetchDataCommand extends DataCommand {
  /// Server response
  final DalFetchResponse response;

  SaveFetchDataCommand({
    required this.response,
    required super.reason,
  });

  @override
  String toString() {
    return 'SaveFetchDataCommand{response: $response, ${super.toString()}}';
  }
}
