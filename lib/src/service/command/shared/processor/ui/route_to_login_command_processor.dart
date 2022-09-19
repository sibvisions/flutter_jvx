import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_to_login_command.dart';
import '../../i_command_processor.dart';

class RouteToLoginCommandProcessor extends ICommandProcessor<RouteToLoginCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToLoginCommand command) async {
    IUiService().routeToLogin(mode: command.mode, pLoginProps: command.loginData);

    return [];
  }
}
