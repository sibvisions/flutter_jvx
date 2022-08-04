import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/custom_screen.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/menu/menu_model.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/config_util.dart';
import '../../util/offline_util.dart';
import '../drawer/drawer_menu.dart';
import 'grid/app_menu_grid_grouped.dart';
import 'grid/app_menu_grid_ungroup.dart';
import 'list/app_menu_list_ungroup.dart';
import 'tab/app_menu_tab.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function(
    {required String componentId, required IUiService pUiService, required BuildContext pContext});

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static void menuItemPressed(
      {required String componentId, required IUiService pUiService, required BuildContext pContext}) {
    CustomScreen? customScreen = pUiService.getCustomScreen(pScreenName: componentId);

    pUiService.setRouteContext(pContext: pContext);

    // Offline screens no not require the server to know that they are open
    if (customScreen != null && !pUiService.hasReplaced(pScreenLongName: customScreen.screenLongName)) {
      pUiService.routeToCustom(pFullPath: "/workScreen/$componentId");
    } else {
      pUiService.sendCommand(OpenScreenCommand(componentId: componentId, reason: "Menu Item was pressed"));
    }
  }
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
  Widget build(BuildContext pContext) {
    if (mounted) {
      getUiService().setRouteContext(pContext: pContext);
    }

    List<Widget> actions = [];

    if (getConfigService().isOffline()) {
      actions.add(
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              getUiService().setRouteContext(pContext: pContext);
              showSyncDialog().then(
                (value) {
                  if (value == true) {
                    OfflineUtil.initOnline(context);
                  }
                },
              );
            },
            icon: const FaIcon(FontAwesomeIcons.broadcastTower),
          ),
        ),
      );
    }

    actions.add(
      Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: const FaIcon(FontAwesomeIcons.ellipsisV),
        ),
      ),
    );

    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      endDrawer: const DrawerMenu(),
      appBar: AppBar(
        title: Text(getConfigService().translateText("Menu")),
        centerTitle: false,
        actions: actions,
      ),
      body: _getMenu(),
    );
  }

  Future<bool?> showSyncDialog() {
    return getUiService().openDialog<bool>(
      pDialogWidget: AlertDialog(
        title: Text(
          getConfigService().translateText("Synchronization"),
        ),
        content: Text(
          getConfigService().translateText(
            "Do you want to switch back online and synchronize all the data?",
          ),
        ),
        actions: [
          TextButton(
            child: Text(getConfigService().translateText("No")),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(getConfigService().translateText("Yes")),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      pIsDismissible: true,
    );
  }

  Widget _getMenu() {
    MenuMode menuMode = ConfigUtil.getMenuMode(getConfigService().getAppStyle()?["menu.mode"]);
    getConfigService().setMenuMode(menuMode);

    MenuFactory menuBuilder = menuFactory[menuMode]!;

    Color? menuBackgroundColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?['desktop.color']);
    String? menuBackgroundImage = getConfigService().getAppStyle()?['desktop.icon'];

    return menuBuilder(
      menuModel: widget.menuModel,
      onClick: AppMenu.menuItemPressed,
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
