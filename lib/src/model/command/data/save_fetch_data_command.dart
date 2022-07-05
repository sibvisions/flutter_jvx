import '../../api/response/dal_fetch_response.dart';
import 'data_command.dart';

class SaveFetchDataCommand extends DataCommand {
  /// Server response
  final DalFetchResponse response;

  SaveFetchDataCommand({
    required this.response,
    required String reason,
  }) : super(reason: reason);

  @override
  String get logString => "SaveFetchDataCommand: response: $response, reason: $reason";
}
