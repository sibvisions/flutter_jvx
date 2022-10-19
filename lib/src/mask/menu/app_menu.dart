import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/app_manager.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../util/offline_util.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';
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
class AppMenu extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenu({Key? key}) : super(key: key);

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
      pUiService.sendCommand(OpenScreenCommand(screenLongName: pScreenLongName, reason: "Menu Item was pressed"));
    }
  }
}

class _AppMenuState extends State<AppMenu> {
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

    if (IConfigService().isOffline()) {
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

    if (kDebugMode) {
      actions.add(IconButton(
        onPressed: () async {
          //Add your debug code here
        },
        icon: const FaIcon(FontAwesomeIcons.bug),
      ));
    }

    Widget body = Column(
      children: [
        if (IConfigService().isOffline()) OfflineUtil.getOfflineBar(context),
        Expanded(child: _getMenu()),
      ],
    );

    FrameState? frame = FrameState.of(context);
    if (frame != null) {
      actions.addAll(frame.getActions());
    }

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      drawer: frame?.getDrawer(context),
      endDrawer: frame?.getEndDrawer(context),
      appBar: frame?.getAppBar(actions),
      body: frame?.wrapBody(body) ?? body,
    );
  }

  Future<SyncDialogResult?> showSyncDialog() {
    return IUiService().openDialog(
      pBuilder: (context) => AlertDialog(
        title: Text(
          FlutterJVx.translate("Synchronization"),
        ),
        content: Text(
          FlutterJVx.translate(
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
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(FlutterJVx.translate("Discard Changes")),
                      onPressed: () async {
                        SyncDialogResult? result = await IUiService().openDialog(
                          pBuilder: (subContext) => AlertDialog(
                            title: Text(FlutterJVx.translate("Discard Offline Changes")),
                            content: Text(FlutterJVx.translate(
                                "Are you sure you want to discard all the changes you made in offline mode?")),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(subContext).pop(SyncDialogResult.NO),
                                child: Text(FlutterJVx.translate("No")),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                onPressed: () => Navigator.of(subContext).pop(SyncDialogResult.DISCARD_CHANGES),
                                child: Text(FlutterJVx.translate("Yes")),
                              ),
                            ],
                          ),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(result);
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                child: Text(FlutterJVx.translate("No")),
                onPressed: () => Navigator.of(context).pop(SyncDialogResult.NO),
              ),
              TextButton(
                child: Text(FlutterJVx.translate("Yes")),
                onPressed: () => Navigator.of(context).pop(SyncDialogResult.YES),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMenu() {
    MenuMode menuMode = IConfigService().getMenuMode();

    // Overriding menu mode
    AppManager? customAppManager = IUiService().getAppManager();
    menuMode = customAppManager?.getMenuMode(menuMode) ?? menuMode;

    MenuFactory menuBuilder = menuFactory[menuMode]!;

    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? menuBackgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? menuBackgroundImage = appStyle['desktop.icon'];

    return menuBuilder(
      menuModel: IUiService().getMenuModel(),
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
