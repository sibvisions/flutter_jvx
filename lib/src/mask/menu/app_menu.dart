import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/app_manager.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../util/offline_util.dart';
import '../../util/search_mixin.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';
import 'grid/app_menu_grid_grouped.dart';
import 'grid/app_menu_grid_ungroup.dart';
import 'list/app_menu_list_grouped.dart';
import 'list/app_menu_list_ungroup.dart';
import 'tab/app_menu_tab.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function(
  BuildContext context, {
  required String pScreenLongName,
});

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

  const AppMenu({super.key});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<AppMenu> createState() => _AppMenuState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static void menuItemPressed(BuildContext context, {required String pScreenLongName}) {
    //Always close drawer even on route (e.g. previewer blocks routing)
    Scaffold.maybeOf(context)?.closeEndDrawer();

    // Offline screens no not require the server to know that they are open
    if (UiService().usesNativeRouting(pScreenLongName: pScreenLongName)) {
      UiService().routeToCustom(pFullPath: "/workScreen/$pScreenLongName");
    } else {
      UiService().sendCommand(OpenScreenCommand(screenLongName: pScreenLongName, reason: "Menu Item was pressed"));
    }
  }
}

class _AppMenuState extends State<AppMenu> with SearchMixin {
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
  Widget build(BuildContext context) {
    return Frame.wrapWithFrame(
      forceWeb: IConfigService().isWebOnly(),
      forceMobile: IConfigService().isMobileOnly(),
      builder: (context, isOffline) => ValueListenableBuilder<MenuModel>(
        valueListenable: IUiService().getMenuNotifier(),
        builder: (context, _, child) {
          List<Widget> actions = [];

          var menuModel = IUiService().getMenuModel();

          if (!isMenuSearchEnabled && menuModel.count >= 8) {
            actions.add(IconButton(
              onPressed: () {
                isMenuSearchEnabled = true;
                menuSearchController.clear();
                setState(() {});
              },
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 22),
            ));
          }

          if (isOffline) {
            actions.add(Builder(
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
            ));
          }

          Widget body = Column(
            children: [
              if (isOffline) OfflineUtil.getOfflineBar(context),
              Expanded(
                child: _getMenu(applyMenuFilter(menuModel, (item) => item.label)),
              ),
            ],
          );

          FrameState? frame = FrameState.of(context);
          if (frame != null) {
            actions.addAll(frame.getActions());
          }

          return WillPopScope(
            onWillPop: () async {
              if (isMenuSearchEnabled) {
                isMenuSearchEnabled = false;
                setState(() {});
                return false;
              }
              return true;
            },
            child: Scaffold(
              drawerEnableOpenDragGesture: false,
              endDrawerEnableOpenDragGesture: false,
              drawer: frame?.getDrawer(context),
              endDrawer: frame?.getEndDrawer(context),
              appBar: frame?.getAppBar(
                leading: isMenuSearchEnabled
                    ? IconButton(
                        onPressed: () {
                          isMenuSearchEnabled = false;
                          setState(() {});
                        },
                        icon: const FaIcon(FontAwesomeIcons.circleXmark))
                    : null,
                title: !isMenuSearchEnabled ? Text(FlutterJVx.translate("Menu")) : _buildSearch(context),
                titleSpacing: isMenuSearchEnabled ? 0.0 : null,
                backgroundColor: isOffline ? Colors.grey.shade500 : null,
                actions: actions,
              ),
              body: frame?.wrapBody(body) ?? body,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && menuSearchController.text.isEmpty) {
          isMenuSearchEnabled = false;
          setState(() {});
        }
      },
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: FlutterJVx.translate("Search"),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          suffixIcon: menuSearchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    menuSearchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        cursorColor: Theme.of(context).colorScheme.onPrimary,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        autofocus: true,
        controller: menuSearchController,
        onSubmitted: (_) => updateMenuFilter(),
        textInputAction: TextInputAction.search,
      ),
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

  Widget _getMenu(MenuModel menuModel) {
    MenuMode menuMode = IConfigService().getMenuMode();

    // Overriding menu mode
    AppManager? customAppManager = IUiService().getAppManager();
    menuMode = customAppManager?.getMenuMode(menuMode) ?? menuMode;

    MenuFactory menuBuilder = menuFactory[menuMode]!;

    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? menuBackgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? menuBackgroundImage = appStyle['desktop.icon'];

    return menuBuilder(
      menuModel: menuModel,
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
