import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/grid/app_menu_grid_grouped.dart';
import 'package:flutter_client/src/mask/menu/grid/app_menu_grid_ungroup.dart';
import 'package:flutter_client/src/mask/menu/grid/widget/app_menu_grid_header.dart';
import 'package:flutter_client/src/mask/menu/tab/app_menu_tab.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/change_password_command.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/api/reset_password_command.dart';
import 'package:flutter_client/src/model/menu/menu_group_model.dart';
import 'package:flutter_client/src/service/config/i_config_service.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/device_status_command.dart';

import '../../model/menu/menu_model.dart';
import 'grid/widget/app_menu_grid_group.dart';
import 'list/app_menu_list_ungroup.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function({required String componentId});

/// Used for menuFactory map
typedef MenuFactory = Widget Function({
  required MenuModel menuModel,
  required ButtonCallback onClick
});

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
    Size screenSize = MediaQuery.of(context).size;
    uiService.sendCommand(DeviceStatusCommand(
        screenHeight: screenSize.height,
        screenWidth: screenSize.width,
        reason: "Menu has been opened"));

    return Scaffold(
        appBar: AppBar(
          title: const Text("Menu"),

          centerTitle: true,
        ),
        body: _getMenu());
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void menuItemPressed({required String componentId}) {
    OpenScreenCommand command = OpenScreenCommand(
        componentId: componentId,
        reason: "Menu Item was pressed"
    );

    uiService.sendCommand(command);
  }

  Widget _getMenu() {
    MENU_MODE menuMode = configService.getMenuMode();
    MenuFactory? menuBuilder = menuFactory[menuMode];

    if (menuBuilder != null) {
      return menuBuilder(menuModel: menuModel, onClick: menuItemPressed);
    } else {
      return _getGroupedGridMenu(
          menuModel: menuModel, onClick: menuItemPressed);
    }
  }

  Widget _getGroupedGridMenu(
      {required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuGridGrouped(onClick: onClick, menuModel: menuModel);
  }

  Widget _getGridMenuUngrouped(
      {required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuGridUnGroup(menuModel: menuModel, onClick: onClick);
  }

  Widget _getListMenuUngrouped(
      {required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuListUngroup(menuModel: menuModel, onClick: onClick);
  }

  Widget _getTabMenu(
      {required MenuModel menuModel, required ButtonCallback onClick}) {
    return AppMenuTab(menuModel: menuModel, onClick: onClick);
  }
}
