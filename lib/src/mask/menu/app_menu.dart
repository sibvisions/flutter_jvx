import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/drawer/drawer_menu.dart';
import 'package:flutter_client/src/mask/menu/grid/app_menu_grid_grouped.dart';
import 'package:flutter_client/src/mask/menu/grid/app_menu_grid_ungroup.dart';
import 'package:flutter_client/src/mask/menu/tab/app_menu_tab.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/custom/custom_screen.dart';
import 'package:flutter_client/src/service/config/i_config_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/menu/menu_model.dart';
import 'list/app_menu_list_ungroup.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function({required String componentId});

/// Used for menuFactory map
typedef MenuFactory = Widget Function({required MenuModel menuModel, required ButtonCallback onClick});

/// Menu Widget - will display menu items accordingly to the menu mode set in
/// [IConfigService]
class AppMenu extends StatelessWidget with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late final Map<MENU_MODE, MenuFactory> menuFactory = {
    MENU_MODE.GRID_GROUPED: _getGroupedGridMenu,
    MENU_MODE.GRID: _getGridMenuUngrouped,
    MENU_MODE.LIST: _getListMenuUngrouped,
    MENU_MODE.TABS: _getTabMenu
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Menu model, contains all menuGroups and items
  late final MenuModel menuModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenu({
    Key? key,
  }) : super(key: key) {
    menuModel = uiService.getMenuModel();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    uiService.setRouteContext(pContext: context);

    return Scaffold(
        endDrawerEnableOpenDragGesture: false,
        endDrawer: DrawerMenu(),
        appBar: AppBar(
          title: Text(configService.translateText("Menu")),
          centerTitle: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const FaIcon(FontAwesomeIcons.ellipsisV)),
            ),
          ],
        ),
        body: _getMenu());
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void menuItemPressed({required String componentId}) {
    CustomScreen? customScreen = uiService.getCustomScreen(pScreenName: componentId);

    // Offline screens no not require the server to know that they are open
    if (customScreen != null && customScreen.isOfflineScreen) {
      uiService.routeToCustom(pFullPath: "/workScreen/$componentId");
    } else {
      uiService.sendCommand(OpenScreenCommand(componentId: componentId, reason: "Menu Item was pressed"));
    }
  }

  Widget _getMenu() {
    MENU_MODE menuMode = configService.getMenuMode();
    MenuFactory? menuBuilder = menuFactory[menuMode];

    if (menuBuilder != null) {
      return menuBuilder(menuModel: menuModel, onClick: menuItemPressed);
    } else {
      return _getGroupedGridMenu(menuModel: menuModel, onClick: menuItemPressed);
    }
  }

  Widget _getGroupedGridMenu({required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuGridGrouped(onClick: onClick, menuModel: menuModel);
  }

  Widget _getGridMenuUngrouped({required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuGridUnGroup(menuModel: menuModel, onClick: onClick);
  }

  Widget _getListMenuUngrouped({required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuListUngroup(menuModel: menuModel, onClick: onClick);
  }

  Widget _getTabMenu({required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuTab(menuModel: menuModel, onClick: onClick);
  }
}
