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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/reload_command.dart';
import '../../model/command/api/rollback_command.dart';
import '../../model/command/api/save_command.dart';
import '../../model/response/device_status_response.dart';
import '../../routing/locations/work_screen_location.dart';
import '../../service/config/config_controller.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/parse_util.dart';
import '../drawer/web_menu.dart';
import '../setting/settings_page.dart';
import '../state/app_style.dart';
import '../state/loading_bar.dart';
import 'frame.dart';

class WebFrame extends Frame {
  const WebFrame({
    super.key,
    required super.builder,
    required super.isOffline,
  });

  @override
  void openSettings(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  FrameState createState() => WebFrameState();
}

class WebFrameState extends FrameState {
  static const double spacing = 15.0;
  late LayoutMode lastMode;
  late bool showWebMenu;

  @override
  void initState() {
    super.initState();
    showWebMenu = ConfigController().layoutMode.value != LayoutMode.Mini;
    lastMode = ConfigController().layoutMode.value;
    ConfigController().layoutMode.addListener(updatedLayoutMode);
  }

  @override
  void dispose() {
    ConfigController().layoutMode.removeListener(updatedLayoutMode);
    super.dispose();
  }

  /// Handle menu status on [LayoutMode] change
  /// Examples:
  /// * Close menu when changing to [LayoutMode.Mini]
  /// * Reopen menu when changing from [LayoutMode.Mini]
  void updatedLayoutMode() {
    var newMode = ConfigController().layoutMode.value;
    if (lastMode != newMode) {
      if (newMode == LayoutMode.Mini && showWebMenu) {
        showWebMenu = false;
        setState(() {});
      }
      if (newMode != LayoutMode.Mini && lastMode == LayoutMode.Mini && !showWebMenu) {
        showWebMenu = true;
        setState(() {});
      }
    }
    lastMode = newMode;
  }

  void toggleWebMenu() {
    showWebMenu = !showWebMenu;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => InheritedWebFrame(
        showMenu: showWebMenu,
        child: super.build(context),
      );

  @override
  PreferredSizeWidget getAppBar({
    Widget? leading,
    Widget? title,
    double? titleSpacing,
    Color? backgroundColor,
    List<Widget>? actions,
  }) {
    var profileImage = ConfigController().userInfo.value?.profileImage;
    var appStyle = AppStyle.of(context)!;
    var applicationStyle = appStyle.applicationStyle;
    Color? topMenuColor = ParseUtil.parseHexColor(applicationStyle['web.topmenu.color']);
    Color? iconColor = ParseUtil.parseHexColor(applicationStyle['web.topmenu.iconColor']);
    String? imagePath = applicationStyle['web.topmenu.image'];

    bool inWorkscreen = FlutterUI.getBeamerDelegate().currentBeamLocation.runtimeType == WorkScreenLocation;

    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: FaIcon(
            FontAwesomeIcons.bars,
            color: iconColor,
          ),
          onPressed: toggleWebMenu,
        ),
      ),
      titleSpacing: 0.0,
      title: SizedBox(
        height: kToolbarHeight,
        child: imagePath != null
            ? ImageLoader.loadImage(
                imagePath,
              )
            : Image.asset(
                ImageLoader.getAssetPath(
                  FlutterUI.package,
                  "assets/images/logo.png",
                ),
                fit: BoxFit.scaleDown,
              ),
      ),
      centerTitle: false,
      actions: [
        if (appStyle.applicationSettings.rollbackVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowRotateLeft,
                color: iconColor,
              ),
              onPressed:
                  inWorkscreen ? (() => IUiService().sendCommand(RollbackCommand(reason: "Clicked in topbar"))) : null,
            ),
          ),
        if (appStyle.applicationSettings.saveVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.floppyDisk,
                color: iconColor,
              ),
              onPressed:
                  inWorkscreen ? (() => IUiService().sendCommand(SaveCommand(reason: "Clicked in topbar"))) : null,
            ),
          ),
        if (appStyle.applicationSettings.reloadVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowRotateRight,
                color: iconColor,
              ),
              onPressed:
                  inWorkscreen ? (() => IUiService().sendCommand(ReloadCommand(reason: "Clicked in topbar"))) : null,
            ),
          ),
        if (appStyle.applicationSettings.homeVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.house,
                color: iconColor,
              ),
              onPressed: () => IUiService().routeToMenu(),
            ),
          ),
        if (appStyle.applicationSettings.userSettingsVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: Builder(
              builder: (context) => IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.gear,
                  color: iconColor,
                ),
                onPressed: () => widget.openSettings(context),
              ),
            ),
          ),
        if (appStyle.applicationSettings.changePasswordVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.key,
                color: iconColor,
              ),
              onPressed: () => widget.changePassword(),
            ),
          ),
        if (appStyle.applicationSettings.logoutVisible)
          Padding(
            padding: const EdgeInsets.only(right: spacing),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.rightFromBracket,
                color: iconColor,
              ),
              onPressed: () => widget.logout(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: spacing),
          child: Builder(
            builder: (context) => CircleAvatar(
              backgroundColor: Theme.of(context).backgroundColor,
              backgroundImage: profileImage != null ? MemoryImage(profileImage) : null,
              child: profileImage == null
                  ? FaIcon(
                      FontAwesomeIcons.solidUser,
                      color: Colors.grey.shade400,
                      size: 23,
                    )
                  : null,
            ),
          ),
        ),
      ],
      backgroundColor: ConfigController().offline.value ? Colors.grey.shade500 : topMenuColor,
      elevation: ConfigController().offline.value ? 0 : null,
    );
  }

  Widget _buildWebMenu(BuildContext context, bool showMenu, {bool inDrawer = false}) {
    return RepaintBoundary(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Builder(
          builder: (context) => WebMenu(
            showWebMenu: showMenu,
            inDrawer: inDrawer,
          ),
        ),
      ),
    );
  }

  @override
  Widget wrapBody(Widget body) {
    return LoadingBar.wrapLoadingBar(ValueListenableBuilder<LayoutMode>(
      valueListenable: ConfigController().layoutMode,
      builder: (context, value, child) {
        bool showMenu = InheritedWebFrame.of(context).showMenu;
        return Stack(
          children: [
            Row(
              children: [
                _buildWebMenu(context, value != LayoutMode.Mini && showMenu),
                Expanded(flex: 1, child: body),
              ],
            ),
            _buildWebMenu(context, value == LayoutMode.Mini && showMenu, inDrawer: true),
          ],
        );
      },
    ));
  }

  @override
  Widget? getEndDrawer(BuildContext context) => Builder(
        builder: (context) {
          double screenWidth = MediaQuery.of(context).size.width;

          return SizedBox(
            width: max(screenWidth / 4, min(screenWidth, 300)),
            child: const SettingsPage(),
          );
        },
      );
}

class InheritedWebFrame extends InheritedFrame {
  final bool showMenu;

  const InheritedWebFrame({
    super.key,
    required this.showMenu,
    required super.child,
  });

  static InheritedWebFrame of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<InheritedWebFrame>()!;

  @override
  bool updateShouldNotify(covariant InheritedWebFrame oldWidget) {
    return showMenu != oldWidget.showMenu;
  }
}
