import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_close_frame_request.dart';
import 'package:flutter_client/src/model/command/api/close_frame_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class CloseFrameCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<CloseFrameCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseFrameCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiCloseFrameRequest closeFrameRequest = ApiCloseFrameRequest(clientId: clientId, frameName: command.frameName);
      return apiService.sendRequest(request: closeFrameRequest);
    }

    return [
      OpenErrorDialogCommand(
        reason: "No Client Id",
        message: "Could not find client id while trying to send Close Frame Request!",
      )
    ];
  }
}
