import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/delete_screen_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/close_screen_response.dart';
import '../i_response_processor.dart';

class CloseScreenProcessor implements IResponseProcessor<CloseScreenResponse> {
  @override
  List<BaseCommand> processResponse(CloseScreenResponse pResponse, IApiRequest? pRequest) {
    List<BaseCommand> commands = [];

    CloseScreenResponse closeScreenResponse = pResponse;
    commands.add(DeleteScreenCommand(
      screenName: closeScreenResponse.screenName,
      reason: "reason",
    ));

    return commands;
  }
}
