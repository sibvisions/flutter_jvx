import 'package:flutter/material.dart';

import '../../model/command/api/open_screen_command.dart';
import '../../model/menu/menu_model.dart';
import '../../service/ui/i_ui_service.dart';
import 'grid/grid_menu.dart';
import 'list/list_menu.dart';
import 'menu_page.dart';
import 'tab/tab_menu.dart';

abstract class Menu extends StatelessWidget {
  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final ButtonCallback onClick;

  const Menu({
    super.key,
    required this.menuModel,
    required this.onClick,
  });

  factory Menu.fromMode(
    MenuMode menuMode, {
    Key? key,
    required MenuModel menuModel,
    ButtonCallback onClick = Menu.menuItemPressed,
    bool grouped = false,
    bool sticky = true,
    bool groupOnlyOnMultiple = true,
  }) {
    switch (menuMode) {
      case MenuMode.LIST:
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
      case MenuMode.DRAWER:
      case MenuMode.SWIPER:
      case MenuMode.GRID:
      case MenuMode.GRID_GROUPED:
      default:
        return GridMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: grouped,
          sticky: sticky,
          groupOnlyOnMultiple: groupOnlyOnMultiple,
        );
    }
  }

  static void menuItemPressed(BuildContext context, {required String pScreenLongName}) {
    //Always close drawer even on route (e.g. previewer blocks routing)
    Scaffold.maybeOf(context)?.closeEndDrawer();

    // Offline screens no not require the server to know that they are open
    if (IUiService().usesNativeRouting(pScreenLongName: pScreenLongName)) {
      IUiService().routeToCustom(pFullPath: "/workScreen/$pScreenLongName");
    } else {
      IUiService().sendCommand(OpenScreenCommand(screenLongName: pScreenLongName, reason: "Menu Item was pressed"));
    }
  }
}

enum MenuMode {
  GRID,
  // Legacy mode
  GRID_GROUPED,
  LIST,
  // Legacy mode
  LIST_GROUPED,
  DRAWER,
  SWIPER,
  TABS,
}
