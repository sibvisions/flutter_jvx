import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_close_screen_request.dart';
import '../../i_command_processor.dart';

class CloseScreenCommandProcessor with ApiServiceMixin implements ICommandProcessor<CloseScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseScreenCommand command) {
    return getApiService().sendRequest(
      request: ApiCloseScreenRequest(
        screenName: command.screenName,
      ),
    );
  }
}
