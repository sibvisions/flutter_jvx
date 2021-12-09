
import 'dart:developer';

import 'package:flutter_client/src/routing/app_routing_type.dart';

import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_command.dart';
import '../../../../../model/component/fl_component_model.dart';
import '../../../../../model/menu/menu_model.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Tells [IUiService] to Route to specified Screen, additional data will be pulled from other services if needed.
// Author: Michael Schober
class RouteCommandProcessor with UiServiceGetterMixin, StorageServiceMixin implements ICommandProcessor<RouteCommand> {

  @override
  Future<List<BaseCommand>> processCommand(RouteCommand command) async {
    // Menu
    if(command.routeType == AppRoutingType.menu) {
      MenuModel? menuModel = await storageService.getMenu();

      getUiService().routeToMenu(menuModel);
    }

    // WorkScreen
    if(command.routeType == AppRoutingType.workScreen) {
      String? screenName = command.screenName;
      if(screenName != null) {
        List<FlComponentModel> screen = await storageService.getScreenByScreenClassName(screenName);
        getUiService().routeToWorkScreen(screen);
      }
    }

    return [];
  }
}