import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/open_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_open_tab_request.dart';
import '../../i_command_processor.dart';

class OpenTabCommandProcessor with ApiServiceGetterMixin implements ICommandProcessor<OpenTabCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenTabCommand command) async {
    return getApiService().sendRequest(
      request: ApiOpenTabRequest(
        index: command.index,
        componentName: command.componentName,
      ),
    );
  }
}
