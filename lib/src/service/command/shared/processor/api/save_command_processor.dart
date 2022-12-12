import '../../../../../model/command/api/save_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_save_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class SaveCommandProcessor implements ICommandProcessor<SaveCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveCommand command) {
    return IApiService().sendRequest(
      ApiSaveRequest(),
    );
  }
}
