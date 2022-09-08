import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_open_screen_request.dart';
import '../../i_command_processor.dart';
import '../ui/update_components_processor.dart';

class OpenScreenCommandProcessor with ApiServiceGetterMixin implements ICommandProcessor<OpenScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenScreenCommand command) async {
    UpdateComponentsProcessor.isOpenScreen = true;

    return getApiService().sendRequest(
      request: ApiOpenScreenRequest(
        screenLongName: command.screenLongName,
        screenClassName: command.screenClassName,
        manualClose: true,
      ),
    );
  }
}
