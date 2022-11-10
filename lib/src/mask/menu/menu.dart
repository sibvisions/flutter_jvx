import 'package:flutter/widgets.dart';

import '../../model/menu/menu_model.dart';
import 'app_menu.dart';
import 'grid/app_menu_grid_grouped.dart';
import 'grid/app_menu_grid_ungroup.dart';
import 'list/app_menu_list_grouped.dart';
import 'list/app_menu_list_ungroup.dart';
import 'tab/app_menu_tab.dart';

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
    required ButtonCallback onClick,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    switch (menuMode) {
      case MenuMode.GRID:
        return AppMenuGridUnGroup(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
      case MenuMode.LIST:
        return AppMenuListUngroup(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
      case MenuMode.LIST_GROUPED:
        return AppMenuListGrouped(
          menuModel: menuModel,
          onClick: onClick,
        );
      case MenuMode.TABS:
        return AppMenuTab(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
      case MenuMode.DRAWER:
      case MenuMode.SWIPER:
      case MenuMode.GRID_GROUPED:
      default:
        return AppMenuGridGrouped(
          menuModel: menuModel,
          onClick: onClick,
          backgroundColor: menuBackgroundColor,
          backgroundImageString: backgroundImageString,
        );
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
