import 'package:flutter/foundation.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_close_screen_request.dart';
import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../i_command_processor.dart';

class CloseScreenCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceMixin
    implements ICommandProcessor<CloseScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseScreenCommand command) {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      return getApiService().sendRequest(
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
