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

import '../../components/panel/fl_panel_wrapper.dart';
import '../../flutter_ui.dart';
import '../../model/menu/menu_item_model.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../state/app_style.dart';
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
      FlutterUI.logUI.wtf("Model/Custom screen not found for work screen: $screenLongName");
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ErrorScreen(
          message: FlutterUI.translate("Failed to load screen, please try again."),
          extra: "Model/Custom screen not found for work screen: $screenLongName",
        ),
      );
    }

    return FocusTraversalGroup(
      child: SafeArea(
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
      ),
    );
  }

  Widget _wrapJVxScreen(
    BuildContext context,
    ScreenWrapper wrappedScreen,
  ) {
    var appStyle = AppStyle.of(context).applicationStyle;
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle?['desktop.color']);
    String? backgroundImageString = appStyle?['desktop.icon'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // If true, rebuilds and therefore can activate scrolling or not.
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

            if (isKeyboardVisible) {
              screenHeight += viewInsets.bottom;
              screenHeight -= viewPadding.bottom;
            }

            Widget screenWidget = wrappedScreen.screen!;
            if (!wrappedScreen.customScreen && screenWidget is FlPanelWrapper) {
              Size size = Size(constraints.maxWidth, screenHeight);
              updateSize(size);
            } else {
              // Wrap custom screen in Positioned
              screenWidget = Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: screenWidget,
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
}
