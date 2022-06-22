import '../../../../model/api/response/close_screen_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/delete_screen_command.dart';
import '../i_processor.dart';

class CloseScreenProcessor implements IProcessor<CloseScreenResponse> {
  @override
  List<BaseCommand> processResponse({required CloseScreenResponse pResponse}) {
    List<BaseCommand> commands = [];

    CloseScreenResponse closeScreenResponse = pResponse;
    commands.add(DeleteScreenCommand(
      screenName: closeScreenResponse.screenName,
      reason: "reason",
    ));

    return commands;
  }
}
