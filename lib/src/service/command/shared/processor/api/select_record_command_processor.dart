import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/api/select_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../model/request/api_select_record_request.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

class SelectRecordCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin, DataServiceGetterMixin
    implements ICommandProcessor<SelectRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SelectRecordCommand command) async {
    IConfigService configService = getConfigService();

    if (configService.isOffline()) {
      return [
        ChangeSelectedRowCommand(
            dataProvider: command.dataProvider, newSelectedRow: command.selectedRecord, reason: command.reason)
      ];
    }
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiSelectRecordRequest apiSelectRecordRequest = ApiSelectRecordRequest(
        clientId: clientId,
        dataProvider: command.dataProvider,
        selectedRow: command.selectedRecord,
        fetch: command.fetch,
        filter: command.filter,
        reload: command.reload,
      );

      return getApiService().sendRequest(request: apiSelectRecordRequest);
    } else {
      return [
        OpenErrorDialogCommand(reason: "NO CLIENT ID", message: "NO CLIENT ID FOUND WHILE TRYING TO SEND SELECT RECORD")
      ];
    }
  }
}
