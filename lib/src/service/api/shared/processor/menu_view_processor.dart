/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:beamer/beamer.dart';

import '../../../../commands.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../../../model/menu/menu_model.dart';
import '../../../../model/request/api_reload_menu_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/menu_view_response.dart';
import '../../../apps/i_app_service.dart';
import '../../../config/i_config_service.dart';
import '../../../storage/i_storage_service.dart';
import '../i_response_processor.dart';

/// Processes the menu response into a [MenuModel], will try to route to menu,
/// if no other routing actions take precedent.
class MenuViewProcessor implements IResponseProcessor<MenuViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(MenuViewResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];
    MenuViewResponse response = pResponse;

    List<MenuGroupModel> groups = _isolateGroups(response);
    for (MenuGroupModel group in groups) {
      group.items.addAll(_getItemsByGroup(group.name, response.responseMenuItems));
    }
    MenuModel menuModel = MenuModel(menuGroups: groups);

    SaveMenuCommand saveMenuCommand = SaveMenuCommand(menuModel: menuModel, reason: "Server sent menu items");
    commands.add(saveMenuCommand);

    if (!IConfigService().offline.value && pRequest is! ApiReloadMenuRequest) {
      var returnUri = IAppService().getApplicableReturnUri(response.responseMenuItems);
      if (returnUri != null) {
        var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
        commands.add(
          RouteToCommand(
            replaceRoute: lastBeamState.pathPatternSegments.contains("login"),
            uri: returnUri.toString(),
            reason: "Found returnUri",
          ),
        );
      } else {
        commands.add(
          RouteToMenuCommand(
            replaceRoute: true,
            reason: "Server sent a menu, likely on login",
          ),
        );
      }
    }

    List<String> listViableNavigationNames =
        menuModel.menuGroups.expand((group) => group.items).map((menuItem) => menuItem.navigationName).toList();
    for (FlPanelModel openScreenModel in IStorageService().getScreens()) {
      if (!listViableNavigationNames.contains(openScreenModel.screenNavigationName)) {
        commands.add(
          CloseScreenCommand(
            componentName: openScreenModel.name,
            reason: "Screen no longer found in menu item list.",
          ),
        );
      }
    }

    // Reset in every case, either it worked or it won't/shouldn't work next time.
    IAppService().returnUri = null;

    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  List<MenuGroupModel> _isolateGroups(MenuViewResponse menu) {
    List<MenuGroupModel> groups = [];
    for (MenuEntryResponse entry in menu.responseMenuItems) {
      if (!groups.any((element) => element.name == entry.group)) {
        groups.add(MenuGroupModel(
          name: entry.group,
          items: [],
        ));
      }
    }
    return groups;
  }

  List<MenuItemModel> _getItemsByGroup(String groupName, List<MenuEntryResponse> entries) {
    List<MenuItemModel> menuItems = [];
    for (MenuEntryResponse responseMenuEntry in entries) {
      if (responseMenuEntry.group == groupName) {
        MenuItemModel menuItem = MenuItemModel(
          screenLongName: responseMenuEntry.componentId,
          navigationName: responseMenuEntry.navigationName,
          label: responseMenuEntry.text,
          alternativeLabel: responseMenuEntry.quickBarText ?? responseMenuEntry.sideBarText,
          image: responseMenuEntry.image,
        );
        menuItems.add(menuItem);
      }
    }
    return menuItems;
  }
}
