import '../../../../../model/command/api/dal_save_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_dal_save_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class DalSaveCommandProcessor implements ICommandProcessor<DalSaveCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DalSaveCommand command) {
    return IApiService().sendRequest(
      ApiDalSaveRequest(
        dataProvider: command.dataProvider,
        onlySelected: command.onlySelected,
      ),
    );
  }
}
