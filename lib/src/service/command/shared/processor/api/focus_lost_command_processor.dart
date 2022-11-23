import '../../../../../model/command/api/focus_lost_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_focus_lost_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class FocusLostCommandProcessor extends ICommandProcessor<FocusLostCommand> {
  @override
  Future<List<BaseCommand>> processCommand(FocusLostCommand command) async {
    return IApiService().sendRequest(
      ApiFocusLostRequest(
        componentName: command.componentName,
      ),
    );
  }
}
