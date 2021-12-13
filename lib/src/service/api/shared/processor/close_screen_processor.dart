import '../../../../model/api/response/close_screen_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/delete_screen_command.dart';
import '../i_processor.dart';

class CloseScreenProcessor implements IProcessor {
  @override
  List<BaseCommand> processResponse(json) {
    CloseScreenResponse closeScreenResponse = CloseScreenResponse.fromJson(json: json);

    return [DeleteScreenCommand(screenName: closeScreenResponse.componentId, reason: "reason")];
  }
}
