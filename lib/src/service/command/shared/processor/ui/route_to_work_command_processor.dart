import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_work_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class RouteToWorkCommandProcessor extends ICommandProcessor<RouteToWorkCommand>
  with UiServiceGetterMixin{


  @override
  Future<List<BaseCommand>> processCommand(RouteToWorkCommand command) async {

    getUiService().routeToWorkScreen();

    return [];
  }

}