/*
 * Copyright 2023 SIB Visions GmbH
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

import 'package:flutter/widgets.dart';

import '../../../components/components_factory.dart';
import '../../../custom/custom_screen.dart';
import '../../../flutter_ui.dart';
import '../../../model/component/fl_component_model.dart';

class ScreenWrapper {
  /// Title displayed on the top
  final String? screenTitle;

  /// Header
  final PreferredSizeWidget? header;

  /// Footer
  final Widget? footer;

  /// Screen Widget
  final Widget? screen;

  final bool customScreen;

  const ScreenWrapper({
    this.screenTitle,
    this.header,
    this.footer,
    this.screen,
    this.customScreen = false,
  });

  factory ScreenWrapper.jvx(FlPanelModel model) {
    return ScreenWrapper(
      screen: ComponentsFactory.buildWidget(model),
      screenTitle: model.screenTitle!,
    );
  }

  factory ScreenWrapper.empty(String? screenTitle) {
    return ScreenWrapper(
      screen: Container(),
      screenTitle: screenTitle ?? FlutterUI.translate("No title"),
    );
  }

  factory ScreenWrapper.customScreen(
    BuildContext context,
    CustomScreen customScreen,
    ScreenWrapper? screen,
  ) {
    Widget? replaceScreen = customScreen.screenBuilder?.call(context, screen?.screen);

    return ScreenWrapper(
      header: customScreen.headerBuilder?.call(context),
      footer: customScreen.footerBuilder?.call(context),
      screen: replaceScreen ?? screen?.screen,
      screenTitle: customScreen.screenTitle ?? screen?.screenTitle,
      customScreen: replaceScreen != null,
    );
  }
}
