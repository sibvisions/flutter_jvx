import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/api/requests/api_navigation_request.dart';
import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/api/navigation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../i_command_processor.dart';

/// Will send [ApiNavigationRequest] to remote server
class NavigationCommandProcessor
    with UiServiceGetterMixin, ConfigServiceMixin, ApiServiceMixin
    implements ICommandProcessor<NavigationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(NavigationCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiNavigationRequest request = ApiNavigationRequest(screenName: command.openScreen, clientId: clientId);

      List<BaseCommand> commands = await apiService.sendRequest(request: request);

      if (commands.isEmpty) {
        commands.add(CloseScreenCommand(screenName: command.openScreen, reason: "Navigation response was empty"));
        commands.add(DeleteScreenCommand(screenName: command.openScreen, reason: "Navigation response was empty"));
      }

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
