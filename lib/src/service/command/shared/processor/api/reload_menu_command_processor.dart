import '../../../../../model/command/api/reload_menu_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reload_menu_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class ReloadMenuCommandProcessor implements ICommandProcessor<ReloadMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ReloadMenuCommand command) async {
    return IApiService().sendRequest(request: ApiReloadMenuRequest());
  }
}
