import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_to_menu_command.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Takes [RouteToMenuCommand] and tell [IUiService] to route there
class RouteToMenuCommandProcessor implements ICommandProcessor<RouteToMenuCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToMenuCommand command) {
    IUiService().routeToMenu(pReplaceRoute: command.replaceRoute);

    return Future.value([]);
  }
}
