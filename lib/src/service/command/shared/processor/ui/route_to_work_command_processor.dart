import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_to_work_command.dart';
import '../../i_command_processor.dart';

class RouteToWorkCommandProcessor extends ICommandProcessor<RouteToWorkCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(RouteToWorkCommand command) async {
    getUiService().routeToWorkScreen(pScreenName: command.screenName, pReplaceRoute: command.replaceRoute);

    return [];
  }
}
