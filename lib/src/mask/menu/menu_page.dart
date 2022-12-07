import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/subjects.dart';

import '../../custom/app_manager.dart';
import '../../flutter_ui.dart';
import '../../model/menu/menu_model.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/config_util.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../../util/search_mixin.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';
import '../work_screen/work_screen.dart';
import 'menu.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function(
  BuildContext context, {
  required String pScreenLongName,
});

/// Menu Page
///
/// Displays menu items accordingly to the menu mode set in [IConfigService]
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SearchMixin {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  @override
  void initState() {
    super.initState();

    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));
  }

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
                    (value) async {
                      if (value == SyncDialogResult.DISCARD_CHANGES) {
                        await OfflineUtil.discardChanges(context);
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

          var appStyle = AppStyle.of(context)!.applicationStyle!;
          Color? backgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
          String? backgroundImage = appStyle['desktop.icon'];

          Widget body = Column(
            children: [
              if (isOffline) OfflineUtil.getOfflineBar(context),
              Expanded(
                child: Stack(
                  children: [
                    if (backgroundColor != null || backgroundImage != null)
                      WorkScreen.buildBackground(backgroundColor, backgroundImage),
                    _getMenu(
                      key: const PageStorageKey('MainMenu'),
                      appStyle: appStyle,
                      applyMenuFilter(menuModel, (item) => item.label),
                    ),
                  ],
                ),
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
                title: !isMenuSearchEnabled
                    ? Text(FlutterUI.translate("Menu"))
                    : Builder(builder: (context) => _buildSearch(context)),
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
          hintText: FlutterUI.translate("Search"),
          hintStyle: TextStyle(
            color: DefaultTextStyle.of(context).style.color?.withOpacity(0.4),
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
                    color: DefaultTextStyle.of(context).style.color,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        cursorColor: DefaultTextStyle.of(context).style.color,
        style: TextStyle(
          fontSize: 20,
          color: DefaultTextStyle.of(context).style.color,
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
          FlutterUI.translate("Synchronization"),
        ),
        content: Text(
          FlutterUI.translate(
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
                      child: Text(FlutterUI.translate("Discard Changes")),
                      onPressed: () async {
                        SyncDialogResult? result = await IUiService().openDialog(
                          pBuilder: (subContext) => AlertDialog(
                            title: Text(FlutterUI.translate("Discard Offline Changes")),
                            content: Text(FlutterUI.translate(
                                "Are you sure you want to discard all the changes you made in offline mode?")),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(subContext).pop(SyncDialogResult.NO),
                                child: Text(FlutterUI.translate("No")),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                onPressed: () => Navigator.of(subContext).pop(SyncDialogResult.DISCARD_CHANGES),
                                child: Text(FlutterUI.translate("Yes")),
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
                child: Text(FlutterUI.translate("No")),
                onPressed: () => Navigator.of(context).pop(SyncDialogResult.NO),
              ),
              TextButton(
                child: Text(FlutterUI.translate("Yes")),
                onPressed: () => Navigator.of(context).pop(SyncDialogResult.YES),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMenu(
    MenuModel menuModel, {
    Key? key,
    required Map<String, String> appStyle,
  }) {
    MenuMode menuMode = ConfigUtil.getMenuMode(appStyle['menu.mode']);

    // Overriding menu mode
    AppManager? customAppManager = IUiService().getAppManager();
    menuMode = customAppManager?.getMenuMode(menuMode) ?? menuMode;

    if (menuMode == MenuMode.DRAWER) return const SizedBox();

    bool? grouped = ParseUtil.parseBool(appStyle['menu.grouped']) ?? false;
    bool? sticky = ParseUtil.parseBool(appStyle['menu.sticky']) ?? true;
    bool? groupOnlyOnMultiple = ParseUtil.parseBool(appStyle['menu.group_only_on_multiple']) ?? false;

    return Menu.fromMode(
      key: key,
      menuMode,
      menuModel: menuModel,
      grouped: [MenuMode.GRID_GROUPED, MenuMode.LIST_GROUPED].contains(menuMode) || grouped,
      sticky: sticky,
      groupOnlyOnMultiple: groupOnlyOnMultiple,
    );
  }
}

enum SyncDialogResult {
  YES,
  NO,
  DISCARD_CHANGES,
}
