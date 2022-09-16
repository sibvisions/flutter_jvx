import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/close_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_close_tab_request.dart';
import '../../i_command_processor.dart';

class CloseTabCommandProcessor with ApiServiceMixin implements ICommandProcessor<CloseTabCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseTabCommand command) {
    return getApiService().sendRequest(
        request: ApiCloseTabRequest(
      index: command.index,
      componentName: command.componentName,
    ));
  }
}
