import '../../../../../model/command/api/changes_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_changes_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class ChangesCommandProcessor implements ICommandProcessor<ChangesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ChangesCommand command) async {
    return await IApiService().sendRequest(
      request: ApiChangesRequest(),
    );
  }
}
