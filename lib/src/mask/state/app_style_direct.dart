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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../util/jvx_colors.dart';
import '../../util/parse_util.dart';
import 'app_style.dart';

/// This class should be used for accessing simple "theme independent" style options.
/// Don't use it for e.g. coloring app which could depend on light/dark mode
/// If you need context dependent information, use [AppStyle] instead.
class AppStyleDirect {
  Map<String, String>? _applicationStyle;

  AppStyleDirect(Map<String, String>? style) {
    _applicationStyle = style;
  }

  /// Returns whether styles are defined
  bool isValid() {
    return _applicationStyle != null;
  }

  bool isSame(AppStyleDirect other) {
    return _applicationStyle == other._applicationStyle;
  }

  String? style(String propertyName, {BuildContext? context}) {
    if (context != null && !JVxColors.isLightTheme(context)) {
      String? valueDark = _applicationStyle?["dark.$propertyName"];

      if (valueDark != null) {
        return valueDark;
      }
    }

    return _applicationStyle?[propertyName];
  }

  /// Gets the style setting as bool
  bool styleAsBool(String propertyName, {BuildContext? context, bool defaultValue = false}) {
    String? value = style(propertyName, context: context);

    if (value == null) {
      return defaultValue;
    }

    return bool.tryParse(value, caseSensitive: false) ?? defaultValue;
  }

  /// Gets theme color setting
  Color? themeColor() {
    return (kIsWeb ? ParseUtil.parseHexColor(_applicationStyle?[AppStyle.webTopMenuColor]) : null)
      ?? ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeColor]);
  }

  double dialogBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeDialogBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double panelBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themePanelBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double menuBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeMenuBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double tableBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeTableBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double listBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeListBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double listCardBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeListCardBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeListBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double editorBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeEditorBorderRadius])
        ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
        ?? JVxColors.BORDER_RADIUS;
  }

  double? slideButtonBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeSlideButtonBorderRadius]);
  }

  double? slideButtonHandleRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeSlideButtonHandleRadius]);
  }

  double buttonBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeButtonBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  double buttonGroupBorderRadius() {
    return ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeButtonGroupBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeButtonBorderRadius])
      ?? ParseUtil.parseDouble(_applicationStyle?[AppStyle.themeBorderRadius])
      ?? JVxColors.BORDER_RADIUS;
  }

  Color? menuDrawerTopColor() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.menuDrawerTopColor]);
  }

  Color? menuDrawerBackground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.menuDrawerBackground]);
  }

  Color? buttonBackground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeButtonBackground]);
  }

  Color? buttonForeground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeButtonForeground]);
  }

  Color? textButtonForeground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeTextButtonForeground ]);
  }

  Color? outlinedButtonForeground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeOutlinedButtonForeground]);
  }

  Color? tableFloatingButtonBackground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeTableFloatingButtonBackground])
      ?? buttonBackground();
  }

  Color? tableFloatingButtonForeground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeTableFloatingButtonForeground])
      ?? buttonForeground();
  }

  Color? listFloatingButtonBackground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeListFloatingButtonBackground])
        ?? buttonBackground();
  }

  Color? listFloatingButtonForeground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeListFloatingButtonForeground])
        ?? buttonForeground();
  }

  Color? groupHeaderBackground() {
    return ParseUtil.parseHexColor(_applicationStyle?[AppStyle.themeGroupHeaderBackground]);
  }

}
