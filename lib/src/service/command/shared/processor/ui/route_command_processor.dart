import 'dart:developer';

import 'package:flutter_client/src/mixin/storage_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/route_command.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/src/routing/app_routing_options.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

///
/// Tells [IUiService] to Route to specified Screen, additional data will be pulled from other services if needed.
///
class RouteCommandProcessor with UiServiceGetterMixin, StorageServiceMixin implements ICommandProcessor<RouteCommand> {

  @override
  Future<List<BaseCommand>> processCommand(RouteCommand command) async {
    if(command.routeTo == AppRoutingOptions.menu) {
      MenuModel menuModel = storageService.getMenu();
      getUiService().routeToMenu(menuModel);
    } else if(command.routeTo == AppRoutingOptions.workScreen) {
      String? screenName = command.screenName;
      if(screenName != null) {
        getUiService().routeToWorkScreen(storageService.getScreenByScreenClassName(screenName));
      }
    }

    return [];
  }
}