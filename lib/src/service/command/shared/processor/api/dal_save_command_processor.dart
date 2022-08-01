import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/request/api_dal_save_request.dart';
import '../../../../../model/command/api/dal_save_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class DalSaveCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<DalSaveCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DalSaveCommand command) {
    ApiDalSaveRequest dalSaveRequest = ApiDalSaveRequest(
      clientId: getConfigService().getClientId()!,
      dataProvider: command.dataProvider,
      onlySelected: command.onlySelected,
    );

    return getApiService().sendRequest(request: dalSaveRequest);
  }
}
