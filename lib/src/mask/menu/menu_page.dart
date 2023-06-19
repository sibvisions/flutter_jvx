/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';

import '../../components/components_factory.dart';
import '../../custom/app_manager.dart';
import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/menu/menu_item_model.dart';
import '../../model/menu/menu_model.dart';
import '../../service/apps/app_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/layout/i_layout_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/config_util.dart';
import '../../util/misc/dialog_result.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../../util/search_mixin.dart';
import '../frame/frame.dart';
import '../frame/web_frame.dart';
import '../state/app_style.dart';
import '../work_screen/work_screen.dart';
import 'menu.dart';

/// Each menu item does get this callback
typedef ButtonCallback = void Function(
  BuildContext context, {
  required MenuItemModel item,
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
  /// Debounce re-layouts
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  bool sentScreen = false;

  @override
  void initState() {
    super.initState();

    IUiService().getAppManager()?.onMenuPage();
    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));
  }

  @override
  Widget build(BuildContext context) {
    return Frame.wrapWithFrame(
      builder: (context, isOffline) => ValueListenableBuilder<MenuModel>(
        valueListenable: IUiService().getMenuNotifier(),
        builder: (context, _, child) => ValueListenableBuilder<FlComponentModel?>(
          valueListenable: IStorageService().getDesktopPanelNotifier(),
          builder: (context, desktopPanel, child) {
            List<Widget> actions = [];

            var menuModel = IUiService().getMenuModel();

            if (!isMenuSearchEnabled && menuModel.count >= 8) {
              actions.add(IconButton(
                tooltip: FlutterUI.translate("Search"),
                splashRadius: kToolbarHeight / 2,
                onPressed: () {
                  isMenuSearchEnabled = true;
                  menuSearchController.clear();
                  setState(() {});
                },
                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 22),
              ));
            }

            if (isOffline) {
              actions.add(IconButton(
                tooltip: FlutterUI.translate("Go Online"),
                splashRadius: kToolbarHeight / 2,
                onPressed: () {
                  showSyncDialog().then(
                    (value) async {
                      switch (value) {
                        case DialogResult.YES:
                          unawaited(OfflineUtil.initOnline());
                          break;
                        case DialogResult.DISCARD_CHANGES:
                          unawaited(OfflineUtil.initOnline(true));
                          break;
                        default:
                      }
                    },
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.towerBroadcast),
              ));
            }

            var appStyle = AppStyle.of(context).applicationStyle;
            Color? backgroundColor = ParseUtil.parseHexColor(appStyle?['desktop.color']);
            String? backgroundImage = appStyle?['desktop.icon'];

            FrameState? frameState = Frame.maybeOf(context);
            if (frameState != null) {
              actions.addAll(frameState.getActions());
            }

            Widget? body;

            if (frameState is WebFrameState && desktopPanel != null) {
              Widget screen = ComponentsFactory.buildWidget(desktopPanel);

              body = getScreen(screen);
            }

            body ??= Column(
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

            return WillPopScope(
              onWillPop: () async {
                if (isMenuSearchEnabled) {
                  isMenuSearchEnabled = false;
                  setState(() {});
                  return false;
                } else if (AppService().startedManually) {
                  unawaited(IUiService().routeToAppOverview());
                  return false;
                }
                return true;
              },
              child: Scaffold(
                drawerEnableOpenDragGesture: false,
                endDrawerEnableOpenDragGesture: false,
                drawer: frameState?.getDrawer(context),
                endDrawer: frameState?.getEndDrawer(context),
                appBar: frameState?.getAppBar(
                  leading: isMenuSearchEnabled
                      ? IconButton(
                          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                          splashRadius: kToolbarHeight / 2,
                          onPressed: () => Navigator.maybePop(context),
                          icon: const FaIcon(FontAwesomeIcons.circleXmark),
                        )
                      : (AppService().startedManually
                          ? IconButton(
                              tooltip: FlutterUI.translate("Exit App"),
                              splashRadius: kToolbarHeight / 2,
                              icon: const BackButtonIcon(),
                              onPressed: () => Navigator.maybePop(context),
                            )
                          : null),
                  title: !isMenuSearchEnabled
                      ? Text(FlutterUI.translate("Menu"))
                      : Builder(builder: (context) => _buildSearch(context)),
                  titleSpacing: isMenuSearchEnabled || AppService().startedManually ? 0.0 : null,
                  backgroundColor: isOffline ? Colors.grey.shade500 : null,
                  actions: actions,
                ),
                body: frameState?.wrapBody(body) ?? body,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && menuSearchController.text.isEmpty) {
          Navigator.maybePop(context);
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
                  tooltip: FlutterUI.translate("Clear"),
                  splashRadius: kToolbarHeight / 2,
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

  Future<DialogResult?> showSyncDialog() {
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
        actionsOverflowAlignment: OverflowBarAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(FlutterUI.translate("Discard changes")),
              onPressed: () async {
                DialogResult? result = await IUiService().openDialog(
                  pBuilder: (subContext) => AlertDialog(
                    title: Text(FlutterUI.translate("Discard offline changes")),
                    content: Text(FlutterUI.translate(
                        "Are you sure you want to discard all the changes you made in offline mode?")),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(subContext).pop(DialogResult.NO),
                        child: Text(FlutterUI.translate("No")),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                        onPressed: () => Navigator.of(subContext).pop(DialogResult.DISCARD_CHANGES),
                        child: Text(FlutterUI.translate("Yes")),
                      ),
                    ],
                  ),
                );
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(result);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text(FlutterUI.translate("No")),
                onPressed: () => Navigator.of(context).pop(DialogResult.NO),
              ),
              TextButton(
                child: Text(FlutterUI.translate("Yes")),
                onPressed: () => Navigator.of(context).pop(DialogResult.YES),
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
    required Map<String, String>? appStyle,
  }) {
    MenuMode menuMode = ConfigUtil.getMenuMode(appStyle?['menu.mode']);

    // Overriding menu mode
    AppManager? customAppManager = IUiService().getAppManager();
    menuMode = customAppManager?.onMenuMode(menuMode) ?? menuMode;

    if (menuMode == MenuMode.DRAWER) return const SizedBox();

    bool? grouped = ParseUtil.parseBool(appStyle?['menu.grouped']) ?? false;
    bool? sticky = ParseUtil.parseBool(appStyle?['menu.sticky']) ?? true;
    bool? groupOnlyOnMultiple = ParseUtil.parseBool(appStyle?['menu.group_only_on_multiple']) ?? false;

    return Menu.fromMode(
      key: key,
      menuMode,
      menuModel: menuModel,
      // ignore: deprecated_member_use_from_same_package
      grouped: [MenuMode.GRID_GROUPED, MenuMode.LIST_GROUPED].contains(menuMode) || grouped,
      sticky: sticky,
      groupOnlyOnMultiple: groupOnlyOnMultiple,
    );
  }

  _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: IStorageService().getDesktopPanelNotifier().value!.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }

  Widget? getScreen(Widget screen) {
    return IgnorePointer(
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) => LayoutBuilder(
          builder: (context, constraints) {
            final viewInsets = EdgeInsets.fromViewPadding(
              View.of(context).viewInsets,
              View.of(context).devicePixelRatio,
            );

            final viewPadding = EdgeInsets.fromViewPadding(
              View.of(context).viewPadding,
              View.of(context).devicePixelRatio,
            );

            double screenHeight = constraints.maxHeight;

            if (isKeyboardVisible) {
              screenHeight += viewInsets.bottom;
              screenHeight -= viewPadding.bottom;
            }

            Size size = Size(constraints.maxWidth, screenHeight);
            if (!sentScreen) {
              _setScreenSize(size);
              sentScreen = true;
            } else {
              subject.add(size);
            }

            return SingleChildScrollView(
              physics: isKeyboardVisible ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  SizedBox(
                    height: screenHeight,
                    width: constraints.maxWidth,
                  ),
                  screen
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
