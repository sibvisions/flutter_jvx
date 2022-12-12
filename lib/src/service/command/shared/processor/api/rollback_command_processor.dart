import '../../../../../model/command/api/rollback_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_rollback_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class RollbackCommandProcessor implements ICommandProcessor<RollbackCommand> {
  @override
  Future<List<BaseCommand>> processCommand(RollbackCommand command) {
    return IApiService().sendRequest(
      ApiRollbackRequest(),
    );
  }
}
