import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/app_manager.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/parse_util.dart';
import '../../util/offline_util.dart';
import '../../util/search_mixin.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';

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
                title: !isMenuSearchEnabled
                    ? Text(FlutterJVx.translate("Menu"))
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
          hintText: FlutterJVx.translate("Search"),
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

    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? menuBackgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? menuBackgroundImage = appStyle['desktop.icon'];

    return Menu.fromMode(
      menuMode,
      menuModel: menuModel,
      backgroundImageString: menuBackgroundImage,
      menuBackgroundColor: menuBackgroundColor,
    );
  }
}

enum SyncDialogResult {
  YES,
  NO,
  DISCARD_CHANGES,
}
