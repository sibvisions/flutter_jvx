import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../util/config_util.dart';
import '../../../util/parse_util.dart';
import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/custom/custom_screen.dart';
import '../../model/menu/menu_model.dart';
import '../../service/config/i_config_service.dart';
import '../drawer/drawer_menu.dart';
import 'grid/app_menu_grid_grouped.dart';
import 'grid/app_menu_grid_ungroup.dart';
import 'list/app_menu_list_ungroup.dart';
import 'tab/app_menu_tab.dart';

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
class AppMenu extends StatefulWidget with UiServiceGetterMixin {
  /// Menu model, contains all menuGroups and items
  late final MenuModel menuModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenu({
    Key? key,
  }) : super(key: key) {
    menuModel = getUiService().getMenuModel();
  }

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> with UiServiceGetterMixin, ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  late final Map<MenuMode, MenuFactory> menuFactory = {
    MenuMode.GRID_GROUPED: _getGroupedGridMenu,
    MenuMode.GRID: _getGridMenuUngrouped,
    MenuMode.LIST: _getListMenuUngrouped,
    MenuMode.TABS: _getTabMenu
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    if (mounted) {
      getUiService().setRouteContext(pContext: context);
    }

    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      endDrawer: const DrawerMenu(),
      appBar: AppBar(
        title: Text(getConfigService().translateText("Menu")),
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
    CustomScreen? customScreen = getUiService().getCustomScreen(pScreenName: componentId);

    getUiService().setRouteContext(pContext: context);

    // Offline screens no not require the server to know that they are open
    if (customScreen != null && customScreen.isOfflineScreen) {
      getUiService().routeToCustom(pFullPath: "/workScreen/$componentId");
    } else {
      getUiService().sendCommand(OpenScreenCommand(componentId: componentId, reason: "Menu Item was pressed"));
    }
  }

  Widget _getMenu() {
    MenuMode menuMode = ConfigUtil.getMenuMode(getConfigService().getAppStyle()?["menu.mode"]);
    getConfigService().setMenuMode(menuMode);

    MenuFactory menuBuilder = menuFactory[menuMode]!;

    Color? menuBackgroundColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?['desktop.color']);
    String? menuBackgroundImage = getConfigService().getAppStyle()?['desktop.icon'];

    return menuBuilder(
      menuModel: widget.menuModel,
      onClick: menuItemPressed,
      backgroundImageString: menuBackgroundImage,
      menuBackgroundColor: menuBackgroundColor,
    );
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
