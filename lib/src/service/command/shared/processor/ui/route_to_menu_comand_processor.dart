import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/routo_to_menu_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

/// Takes [RouteToMenuCommand] and tell [IUiService] to route there
class RouteToMenuCommandProcessor with UiServiceGetterMixin
    implements ICommandProcessor<RouteToMenuCommand> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToMenuCommand command) async {

    getUiService().closeScreen(pScreenName: command.toString());
    getUiService().routeToMenu();

    return [];
  }

}