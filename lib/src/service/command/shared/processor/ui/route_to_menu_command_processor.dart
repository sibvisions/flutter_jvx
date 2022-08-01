import 'package:flutter/foundation.dart';

import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_to_menu_command.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Takes [RouteToMenuCommand] and tell [IUiService] to route there
class RouteToMenuCommandProcessor with UiServiceGetterMixin implements ICommandProcessor<RouteToMenuCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToMenuCommand command) {
    getUiService().routeToMenu(pReplaceRoute: command.replaceRoute);

    return SynchronousFuture([]);
  }
}
