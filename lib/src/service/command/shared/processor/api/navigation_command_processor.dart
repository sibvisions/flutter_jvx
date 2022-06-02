import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_navigation_request.dart';
import 'package:flutter_client/src/model/command/api/navigation_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

/// Will send [ApiNavigationRequest] to remote server
class NavigationCommandProcessor
    with UiServiceGetterMixin, ConfigServiceMixin, ApiServiceMixin
    implements ICommandProcessor<NavigationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(NavigationCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiNavigationRequest request = ApiNavigationRequest(screenName: command.openScreen, clientId: clientId);

      Future<List<BaseCommand>> commands = apiService.sendRequest(request: request);
      commands.then((value) {
        if (value.isEmpty) {
          getUiService().closeScreen(pScreenName: command.openScreen);
          getUiService().routeToMenu(pReplaceRoute: true);
        }
      });

      return commands;
    }

    return [
      OpenErrorDialogCommand(
        reason: "Error sending Navigation request",
        message: "Error sending Navigation request",
      )
    ];
  }
}
