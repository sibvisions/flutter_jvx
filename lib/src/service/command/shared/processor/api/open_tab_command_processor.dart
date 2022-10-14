import '../../../../../model/command/api/open_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_open_tab_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class OpenTabCommandProcessor implements ICommandProcessor<OpenTabCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenTabCommand command) async {
    return IApiService().sendRequest(
      ApiOpenTabRequest(
        index: command.index,
        componentName: command.componentName,
      ),
    );
  }
}
