import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/api/navigation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/request/api_navigation_request.dart';
import '../../i_command_processor.dart';

/// Will send [ApiNavigationRequest] to remote server
class NavigationCommandProcessor with ApiServiceGetterMixin implements ICommandProcessor<NavigationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(NavigationCommand command) async {
    List<BaseCommand> commands = await getApiService().sendRequest(
      request: ApiNavigationRequest(
        screenName: command.openScreen,
      ),
    );

    if (commands.isEmpty) {
      commands.add(CloseScreenCommand(screenName: command.openScreen, reason: "Navigation response was empty"));
      commands.add(DeleteScreenCommand(screenName: command.openScreen, reason: "Navigation response was empty"));
    }

    return commands;
  }
}
