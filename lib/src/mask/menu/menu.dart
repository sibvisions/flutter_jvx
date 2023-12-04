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
import 'package:flutter/material.dart';

import '../../custom/custom_screen.dart';
import '../../flutter_ui.dart';
import '../../model/command/api/activate_screen_command.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/menu/menu_item_model.dart';
import '../../model/menu/menu_model.dart';
import '../../routing/locations/main_location.dart';
import '../../service/command/i_command_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../frame/frame.dart';
import 'grid/grid_menu.dart';
import 'list/list_menu.dart';
import 'tab/tab_menu.dart';

/// Each menu item does get this callback
typedef MenuItemCallback = void Function(
  BuildContext context, {
  required MenuItemModel item,
});

typedef MenuBuilder = Widget? Function(
  BuildContext context,
  Key? key,
  MenuMode mode,
  MenuModel menuModel,
  MenuItemCallback onClick,
  bool grouped,
  bool sticky,
  bool groupOnlyOnMultiple,
);

abstract class Menu extends StatelessWidget {
  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final MenuItemCallback onClick;

  const Menu({
    super.key,
    required this.menuModel,
    required this.onClick,
  });

  /// Returns a Menu depending on the [menuMode].
  ///
  /// [key] is in most cases a [PageStorageKey].
  ///
  /// [menuModel] contains the final menu items which should be shown by the responsible menu implementation.
  ///
  /// [onClick] is the callback that should be executed when a menu item is pressed.
  ///
  /// [grouped] controls whether the items should be grouped by their respective groups, if applicable.
  ///
  /// [sticky] controls whether the group headers should be sticky during scrolling.
  ///
  /// [groupOnlyOnMultiple] controls whether groups should only be shown if there is more than one group.
  /// Is only considered if [grouped] is `true`.
  factory Menu.fromMode(
    MenuMode menuMode, {
    Key? key,
    required MenuModel menuModel,
    required MenuItemCallback onClick,
    bool grouped = false,
    bool sticky = true,
    bool groupOnlyOnMultiple = true,
  }) {
    switch (menuMode) {
      case MenuMode.LIST:
      // ignore: deprecated_member_use_from_same_package
      case MenuMode.LIST_GROUPED:
        return ListMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: grouped,
          sticky: sticky,
          groupOnlyOnMultiple: groupOnlyOnMultiple,
        );
      case MenuMode.TABS:
        return TabMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
        );
      case MenuMode.GRID:
      // ignore: deprecated_member_use_from_same_package
      case MenuMode.GRID_GROUPED:
        return GridMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: grouped,
          sticky: sticky,
          groupOnlyOnMultiple: groupOnlyOnMultiple,
        );
      case MenuMode.DRAWER:
      default:
        return GridMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: true,
          sticky: true,
          groupOnlyOnMultiple: false,
        );
    }
  }

  static void menuItemPressed(BuildContext context, {required MenuItemModel item}) {
    // Always close drawer even on route (Flutter Bug sometimes breaks routing with open drawer)
    Scaffold.maybeOf(context)?.closeEndDrawer();

    var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    // Don't route if we are already there (can create history duplicates when using query parameters; e.g. in deep links)
    if (lastBeamState.pathParameters[MainLocation.screenNameKey] == item.navigationName) {
      return;
    }

    FlPanelModel? model = IStorageService().getComponentByScreenClassName(pScreenClassName: item.screenLongName);
    CustomScreen? customScreen = IUiService().getCustomScreen(item.screenLongName);

    if (customScreen != null && !customScreen.sendOpenScreenRequests) {
      return;
    }

    BaseCommand commandToSend;
    if (model != null) {
      commandToSend = ActivateScreenCommand(reason: "menu item clicked", componentId: model.name);
    } else {
      commandToSend = OpenScreenCommand(reason: "menu item clicked", screenLongName: item.screenLongName);
    }

    ICommandService()
        .sendCommand(commandToSend)
        .then((value) => IUiService().routeToWorkScreen(pScreenName: item.navigationName))
        .catchError(IUiService().handleAsyncError);
  }

  /// Returns the action function based on the [item] parameter.
  static MenuItemCallback? getCloseScreenAction(MenuItemModel item) {
    if (IStorageService().getComponentByNavigationName(item.navigationName) != null) {
      return (BuildContext context, {required MenuItemModel item}) async {
        // Always close drawer as this can prevent the navigator from correctly updating the screen.
        // https://github.com/sibvisions/flutter_jvx/issues/145
        Scaffold.maybeOf(context)?.closeEndDrawer();

        FlPanelModel? workscreenModel = IStorageService().getComponentByNavigationName(item.navigationName);
        if (workscreenModel != null) {
          await IUiService()
              .sendCommand(
                CloseScreenCommand(
                  screenName: workscreenModel.name,
                  reason: "User requested screen closing",
                ),
              )
              .then((value) => Frame.of(context).rebuild());
        }
      };
    }

    return null;
  }
}

enum MenuMode {
  GRID,
  // Legacy mode
  @Deprecated("Only used by old servers, defaults to GRID")
  GRID_GROUPED,
  LIST,
  // Legacy mode
  @Deprecated("Only used by old servers, defaults to LIST")
  LIST_GROUPED,
  DRAWER,
  TABS,
  ;

  factory MenuMode.fromString(String? menuModeString) {
    MenuMode menuMode;
    switch (menuModeString) {
      case "list":
        menuMode = MenuMode.LIST;
        break;
      case "list_grouped":
        // ignore: deprecated_member_use_from_same_package
        menuMode = MenuMode.LIST_GROUPED;
        break;
      case "drawer":
        menuMode = MenuMode.DRAWER;
        break;
      case "tabs":
        menuMode = MenuMode.TABS;
        break;
      case "grid_grouped":
        // ignore: deprecated_member_use_from_same_package
        menuMode = MenuMode.GRID_GROUPED;
        break;
      case "grid":
      default:
        menuMode = MenuMode.GRID;
    }
    return menuMode;
  }

  @Deprecated("Only used to migrate deprecated modes")
  MenuMode migrate() {
    switch (this) {
      // ignore: deprecated_member_use_from_same_package
      case MenuMode.GRID_GROUPED:
        return MenuMode.GRID;
      // ignore: deprecated_member_use_from_same_package
      case MenuMode.LIST_GROUPED:
        return MenuMode.LIST;
      default:
        return this;
    }
  }
}
