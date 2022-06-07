import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_close_screen_request.dart';
import 'package:flutter_client/src/model/command/api/close_screen_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class CloseScreenCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<CloseScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseScreenCommand command) {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      return apiService.sendRequest(
        request: ApiCloseScreenRequest(
          clientId: clientId,
          screenName: command.screenName,
        ),
      );
    } else {
      return SynchronousFuture([
        OpenErrorDialogCommand(
          reason: "NO CLIENT ID FOUND WHILE SENDING CLOSE SCREEN REQUEST",
          message: "NO CLIENT ID FOUND WHILE SENDING CLOSE SCREEN REQUEST",
        ),
      ]);
    }
  }
}
