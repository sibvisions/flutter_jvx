import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_select_record_request.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

import '../../../../../model/command/api/select_record_command.dart';

class SelectRecordCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<SelectRecordCommand> {
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
      return [OpenErrorDialogCommand(reason: "NO CLIENT ID", message: "NO CLIENT ID FOUND WHILE TRYING TO SEND SELECT RECORD")];
    }
  }
}
