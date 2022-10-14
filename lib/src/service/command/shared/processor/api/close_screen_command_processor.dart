import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_close_screen_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class CloseScreenCommandProcessor implements ICommandProcessor<CloseScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseScreenCommand command) {
    return IApiService().sendRequest(
      ApiCloseScreenRequest(
        screenName: command.screenName,
      ),
    );
  }
}
