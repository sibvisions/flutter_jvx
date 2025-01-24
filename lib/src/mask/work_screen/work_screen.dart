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

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../../flutter_jvx.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../util/offline_util.dart';
import 'error_screen.dart';
import 'util/screen_wrapper.dart';
import 'work_screen_page.dart';

/// Renders work screens.
class WorkScreen extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final MenuItemModel item;
  final ScreenWrapper? screen;
  final bool isOffline;
  final void Function(Size size) updateSize;

  const WorkScreen({
    super.key,
    required this.item,
    required this.screen,
    required this.isOffline,
    required this.updateSize,
  });

  String get screenLongName => item.screenLongName;

  @override
  Widget build(BuildContext context) {
    if (screen?.screen == null) {
      FlutterUI.logUI.f("Model/Custom screen not found for work screen: $screenLongName");
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ErrorScreen(
          message: FlutterUI.translate("Failed to load screen, please try again."),
          extra: "Model/Custom screen not found for work screen: $screenLongName",
        ),
      );
    }

    return FocusTraversalGroup(
      child: Column(
        children: [
          if (isOffline) OfflineUtil.getOfflineBar(context),
          Expanded(
            child: _wrapJVxScreen(
              context,
              screen!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapJVxScreen(
    BuildContext context,
    ScreenWrapper wrappedScreen,
  ) {
    AppStyle appStyle = AppStyle.of(context);
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle.style(context, 'desktop.color'));
    String? backgroundImageString = appStyle.style(context, 'desktop.icon');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // If true, resize to enable scrolling, otherwise screen is behind the keyboard.
      appBar: wrappedScreen.header,
      bottomNavigationBar: wrappedScreen.footer,
      backgroundColor: Colors.transparent,
      body: KeyboardVisibilityBuilder(
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

            // View padding is partial display obstructions. (e.g. iphone top notch) Usually removed by the safe area
            // View insets are complete display obstructions. Usually the keyboard.
            // As we already remove the bottom padding through the safe area,
            // so only calculate the insets if they are bigger than the padding
            if (viewInsets.bottom > viewPadding.bottom) {
              screenHeight += viewInsets.bottom;
              screenHeight -= viewPadding.bottom;
            }

            Widget screenWidget = wrappedScreen.screen!;

            if (screenWidget is FlPanelWrapper) {
              updateSize(Size(constraints.maxWidth, screenHeight));
            }

            if (wrappedScreen.customScreen) {
              // Wrap custom screen in Positioned
              screenWidget = Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0,
                child: Stack(children: [screenWidget]),
              );
            }

            return SingleChildScrollView(
              physics: isKeyboardVisible ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  SizedBox(
                    height: screenHeight,
                    width: constraints.maxWidth,
                    child: WorkScreenPage.buildBackground(backgroundColor, backgroundImageString),
                  ),
                  screenWidget
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Sends a [SetParameterCommand].
  static Future<void> setParameter(Map<String, dynamic> parameter) {
    return ICommandService().sendCommand(SetParameterCommand(
      parameter: parameter,
      reason: "SetParameter API",
    ));
  }

  /// Sends a [SetScreenParameterCommand].
  static Future<void> setScreenParameter({
    String? screenLongName,
    required Map<String, dynamic> parameter,
  }) {
    return ICommandService().sendCommand(SetScreenParameterCommand(
      screenLongName: screenLongName,
      parameter: parameter,
      reason: "SetScreenParameter API",
    ));
  }
}
