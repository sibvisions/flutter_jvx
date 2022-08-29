import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/app_manager.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/menu/menu_model.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/offline_util.dart';
import '../drawer/drawer_menu.dart';
import 'grid/app_menu_grid_grouped.dart';
import 'grid/app_menu_grid_ungroup.dart';
import 'list/app_menu_list_grouped.dart';
import 'list/app_menu_list_ungroup.dart';
import 'tab/app_menu_tab.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function(
    {required String pScreenLongName, required IUiService pUiService, required BuildContext pContext});

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
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenu({Key? key}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<AppMenu> createState() => _AppMenuState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static void menuItemPressed(
      {required String pScreenLongName, required IUiService pUiService, required BuildContext pContext}) {
    // Offline screens no not require the server to know that they are open
    if (pUiService.usesNativeRouting(pScreenLongName: pScreenLongName)) {
      pUiService.routeToCustom(pFullPath: "/workScreen/$pScreenLongName");
    } else {
      pUiService.sendCommand(OpenScreenCommand(componentId: pScreenLongName, reason: "Menu Item was pressed"));
    }
  }
}

class _AppMenuState extends State<AppMenu> with UiServiceGetterMixin, ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  late final Map<MenuMode, MenuFactory> menuFactory = {
    MenuMode.GRID_GROUPED: _getGroupedGridMenu,
    MenuMode.GRID: _getGridMenuUngrouped,
    MenuMode.LIST_GROUPED: _getListMenuGrouped,
    MenuMode.LIST: _getListMenuUngrouped,
    MenuMode.TABS: _getTabMenu
  };

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext pContext) {
    List<Widget> actions = [];

    if (getConfigService().isOffline()) {
      actions.add(
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              showSyncDialog().then(
                (value) {
                  if (value == SyncDialogResult.DISCARD_CHANGES) {
                    OfflineUtil.discardChanges(context);
                    OfflineUtil.initOnline();
                  } else if (value == SyncDialogResult.YES) {
                    OfflineUtil.initOnline();
                  }
                },
              );
            },
            icon: const FaIcon(FontAwesomeIcons.towerBroadcast),
          ),
        ),
      );
    }

    actions.add(
      Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
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
        backgroundColor: getConfigService().isOffline() ? Colors.grey.shade500 : null,
        elevation: getConfigService().isOffline() ? 0 : null,
      ),
      body: Column(
        children: [
          if (getConfigService().isOffline()) OfflineUtil.getOfflineBar(context, useElevation: true),
          Expanded(child: _getMenu()),
        ],
      ),
    );
  }

  Future<SyncDialogResult?> showSyncDialog() {
    return getUiService().openDialog(
      pBuilder: (context) => AlertDialog(
        title: Text(
          getConfigService().translateText("Synchronization"),
        ),
        content: Text(
          getConfigService().translateText(
            "Do you want to switch back online and synchronize all the data?",
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(primary: Colors.red),
                      child: Text(getConfigService().translateText("Discard Changes")),
                      onPressed: () async {
                        SyncDialogResult? result = await getUiService().openDialog(
                          pBuilder: (subContext) => AlertDialog(
                            title: Text(getConfigService().translateText("Discard Offline Changes")),
                            content: Text(getConfigService().translateText(
                                "Are you sure you want to discard all the changes you made in offline mode?")),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(subContext).pop(SyncDialogResult.NO),
                                child: Text(getConfigService().translateText("No")),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(primary: Colors.red),
                                onPressed: () => Navigator.of(subContext).pop(SyncDialogResult.DISCARD_CHANGES),
                                child: Text(getConfigService().translateText("Yes")),
                              ),
                            ],
                          ),
                        );
                        Navigator.of(context).pop(result);
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                child: Text(getConfigService().translateText("No")),
                onPressed: () => Navigator.of(context).pop(SyncDialogResult.NO),
              ),
              TextButton(
                child: Text(getConfigService().translateText("Yes")),
                onPressed: () => Navigator.of(context).pop(SyncDialogResult.YES),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMenu() {
    MenuMode menuMode = getConfigService().getMenuMode();

    // Overriding menu mode
    AppManager? customScreenManager = getUiService().getAppManager();
    menuMode = customScreenManager?.getMenuMode(menuMode) ?? menuMode;

    MenuFactory menuBuilder = menuFactory[menuMode]!;

    Color? menuBackgroundColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?['desktop.color']);
    String? menuBackgroundImage = getConfigService().getAppStyle()?['desktop.icon'];

    return menuBuilder(
      menuModel: getUiService().getMenuModel(),
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

  Widget _getListMenuGrouped({
    required MenuModel menuModel,
    required ButtonCallback onClick,
    Color? menuBackgroundColor,
    String? backgroundImageString,
  }) {
    return AppMenuListGrouped(
      menuModel: menuModel,
      onClick: onClick,
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

enum SyncDialogResult {
  YES,
  NO,
  DISCARD_CHANGES,
}
