import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_select_record_request.dart';
import '../../../../../model/command/api/select_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../i_command_processor.dart';

class SelectRecordCommandProcessor
    with ApiServiceMixin, ConfigServiceMixin
    implements ICommandProcessor<SelectRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SelectRecordCommand command) async {
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

      return apiService.sendRequest(request: apiSelectRecordRequest);
    } else {
      return [
        OpenErrorDialogCommand(reason: "NO CLIENT ID", message: "NO CLIENT ID FOUND WHILE TRYING TO SEND SELECT RECORD")
      ];
    }
  }
}
