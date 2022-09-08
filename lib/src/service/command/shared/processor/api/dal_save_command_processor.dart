import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/dal_save_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_dal_save_request.dart';
import '../../i_command_processor.dart';

class DalSaveCommandProcessor with ApiServiceGetterMixin implements ICommandProcessor<DalSaveCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DalSaveCommand command) {
    return getApiService().sendRequest(
        request: ApiDalSaveRequest(
      dataProvider: command.dataProvider,
      onlySelected: command.onlySelected,
    ));
  }
}
