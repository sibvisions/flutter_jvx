import '../../../../../model/command/api/focus_gained_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_focus_gained_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class FocusGainedCommandProcessor extends ICommandProcessor<FocusGainedCommand> {
  @override
  Future<List<BaseCommand>> processCommand(FocusGainedCommand command) async {
    return IApiService().sendRequest(
      ApiFocusGainedRequest(
        componentName: command.componentName,
      ),
    );
  }
}
