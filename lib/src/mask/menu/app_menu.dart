import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/drawer/drawer_menu.dart';
import 'package:flutter_client/src/mask/menu/grid/app_menu_grid_grouped.dart';
import 'package:flutter_client/src/mask/menu/grid/app_menu_grid_ungroup.dart';
import 'package:flutter_client/src/mask/menu/tab/app_menu_tab.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/custom/custom_screen.dart';
import 'package:flutter_client/src/service/config/i_config_service.dart';
import 'package:flutter_client/util/parse_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/menu/menu_model.dart';
import 'list/app_menu_list_ungroup.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function({required String componentId});

/// Used for menuFactory map
typedef MenuFactory = Widget Function({
  required MenuModel menuModel,
  required ButtonCallback onClick,
  Color? menuBackgroundColor,
  String? backgroundImageString,
});

/// Menu Widget - will display menu items accordingly to the menu mode set in
/// [IConfigService]
class AppMenu extends StatefulWidget with UiServiceMixin {
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

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  late final Map<MENU_MODE, MenuFactory> menuFactory = {
    MENU_MODE.GRID_GROUPED: _getGroupedGridMenu,
    MENU_MODE.GRID: _getGridMenuUngrouped,
    MENU_MODE.LIST: _getListMenuUngrouped,
    MENU_MODE.TABS: _getTabMenu
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    if (mounted) {
      uiService.setRouteContext(pContext: context);
    }

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
              icon: const FaIcon(FontAwesomeIcons.ellipsisV),
            ),
          ),
        ],
      ),
      body: _getMenu(),
    );
  }

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
    String? menuModeString = configService.getAppStyle()?["menu.mode"];
    switch (menuModeString) {
      case 'grid_grouped':
        configService.setMenuMode(MENU_MODE.GRID_GROUPED);
        break;
      case 'grid':
        configService.setMenuMode(MENU_MODE.GRID);
        break;
      case 'list':
        configService.setMenuMode(MENU_MODE.LIST);
        break;
      case 'tabs':
        configService.setMenuMode(MENU_MODE.TABS);
        break;
      default:
        configService.setMenuMode(MENU_MODE.GRID_GROUPED);
    }

    MENU_MODE menuMode = configService.getMenuMode();
    MenuFactory? menuBuilder = menuFactory[menuMode];

    Color? menuBackgroundColor = ParseUtil.parseHexColor(configService.getAppStyle()?['desktop.color']);
    String? menuBackgroundImage = configService.getAppStyle()?['desktop.icon'];

    if (menuBuilder != null) {
      return menuBuilder(
        menuModel: widget.menuModel,
        onClick: menuItemPressed,
        backgroundImageString: menuBackgroundImage,
        menuBackgroundColor: menuBackgroundColor,
      );
    } else {
      return _getGroupedGridMenu(
        menuModel: widget.menuModel,
        onClick: menuItemPressed,
        menuBackgroundColor: menuBackgroundColor,
        backgroundImageString: menuBackgroundImage,
      );
    }
  }

  Widget _getGroupedGridMenu({
    required MenuModel menuModel,
    required ButtonCallback onClick,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    return AppMenuGridGrouped(
      onClick: onClick,
      menuModel: menuModel,
      backgroundColor: menuBackgroundColor,
      backgroundImageString: backgroundImageString,
    );
  }

  Widget _getGridMenuUngrouped({
    required MenuModel menuModel,
    required ButtonCallback onClick,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    return AppMenuGridUnGroup(
      menuModel: menuModel,
      onClick: onClick,
      backgroundColor: menuBackgroundColor,
      backgroundImageString: backgroundImageString,
    );
  }

  Widget _getListMenuUngrouped({
    required MenuModel menuModel,
    required ButtonCallback onClick,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    return AppMenuListUngroup(
      menuModel: menuModel,
      onClick: onClick,
      backgroundColor: menuBackgroundColor,
      backgroundImageString: backgroundImageString,
    );
  }

  Widget _getTabMenu({
    required MenuModel menuModel,
    required ButtonCallback onClick,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    return AppMenuTab(
      menuModel: menuModel,
      onClick: onClick,
      backgroundColor: menuBackgroundColor,
      backgroundImageString: backgroundImageString,
    );
  }
}
