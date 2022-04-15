import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_login_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class RouteToLoginCommandProcessor extends ICommandProcessor<RouteToLoginCommand> with UiServiceGetterMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToLoginCommand command) async {

    getUiService().routeToLogin();

    return [];
  }

}