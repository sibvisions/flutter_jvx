import '../../../../../model/command/api/reload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reload_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class ReloadCommandProcessor implements ICommandProcessor<ReloadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ReloadCommand command) {
    return IApiService().sendRequest(
      ApiReloadRequest(),
    );
  }
}
