import 'package:flutter/material.dart';

import '../../../services.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/menu/menu_model.dart';
import 'grid/grid_menu.dart';
import 'grid/grouped_grid_menu.dart';
import 'list/grouped_list_menu.dart';
import 'list/list_menu.dart';
import 'menu_page.dart';
import 'tab/tab_menu.dart';

abstract class Menu extends StatelessWidget {
  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final ButtonCallback onClick;

  ///ImageString of Background Image if Set
  final String? backgroundImageString;

  ///Background Color if Set
  final Color? backgroundColor;

  const Menu({
    super.key,
    required this.menuModel,
    required this.onClick,
    this.backgroundImageString,
    this.backgroundColor,
  });

  factory Menu.fromMode(
    MenuMode menuMode, {
    required MenuModel menuModel,
    ButtonCallback onClick = Menu.menuItemPressed,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    switch (menuMode) {
      case MenuMode.GRID:
        return GridMenu(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
      case MenuMode.LIST:
        return ListMenu(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
      case MenuMode.LIST_GROUPED:
        return GroupedListMenu(
          menuModel: menuModel,
          onClick: onClick,
        );
      case MenuMode.TABS:
        return TabMenu(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
      case MenuMode.DRAWER:
      case MenuMode.SWIPER:
      case MenuMode.GRID_GROUPED:
      default:
        return GroupedGridMenu(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
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
  GRID_GROUPED,
  LIST,
  LIST_GROUPED,
  DRAWER,
  SWIPER,
  TABS,
}
