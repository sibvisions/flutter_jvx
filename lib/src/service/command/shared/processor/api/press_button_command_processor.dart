import '../../../../../model/command/api/press_button_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_press_button_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class PressButtonCommandProcessor implements ICommandProcessor<PressButtonCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PressButtonCommand command) async {
    return IApiService().sendRequest(
      request: ApiPressButtonRequest(
        componentName: command.componentName,
      ),
    );
  }
}
