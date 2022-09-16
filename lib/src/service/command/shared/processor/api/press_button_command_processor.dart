import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/press_button_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_press_button_request.dart';
import '../../i_command_processor.dart';

class PressButtonCommandProcessor with ApiServiceMixin implements ICommandProcessor<PressButtonCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PressButtonCommand command) async {
    return getApiService().sendRequest(
      request: ApiPressButtonRequest(
        componentName: command.componentName,
      ),
    );
  }
}
