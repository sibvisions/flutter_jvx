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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/jvx_colors.dart';
import '../../util/parse_util.dart';
import 'app_style.dart';

/// This class should be used for accessing simple "theme independent" style options.
/// Don't use it for e.g. coloring app which could depend on light/dark mode
/// If you need context dependent information, use [AppStyle] instead.
class AppStyleDirect {
  final Map<String, String>? _applicationStyle;

  final bool _darkMode;

  const AppStyleDirect(
    Map<String, String>? style, {
    bool? darkMode
  }) :
    _applicationStyle = style,
    _darkMode = darkMode ?? false;

  /// Returns a copy with given properties
  AppStyleDirect copyWith({bool? darkMode}) {
    return AppStyleDirect(_applicationStyle, darkMode: darkMode ?? _darkMode);
  }

  /// Returns whether styles are defined
  bool isValid() {
    return _applicationStyle != null;
  }

  bool isSame(AppStyleDirect other) {
    return _applicationStyle == other._applicationStyle && _darkMode == other._darkMode;
  }

  String? style(String propertyName) {
    if (_darkMode) {
      String? valueDark = _applicationStyle?["dark.$propertyName"];

      if (valueDark != null) {
        return valueDark;
      }
    }

    return _applicationStyle?[propertyName];
  }

  /// Gets the style setting as bool
  bool styleAsBool(String propertyName, {bool defaultValue = false}) {
    String? value = style(propertyName);

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
    return ParseUtil.parseDouble(style(AppStyle.themeDialogBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double panelBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themePanelBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double popupMenuBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themePopupMenuBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double tableBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeTableBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double listBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeListBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double listCardBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeListCardBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeListBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double editorBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeEditorBorderRadius))
        ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
        ?? JVxColors.BORDER_RADIUS;
  }

  double? slideButtonBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeSlideButtonBorderRadius));
  }

  double? slideButtonHandleRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeSlideButtonHandleRadius));
  }

  double buttonBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeButtonBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  double buttonGroupBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.themeButtonGroupBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeButtonBorderRadius))
      ?? ParseUtil.parseDouble(style(AppStyle.themeBorderRadius))
      ?? JVxColors.BORDER_RADIUS;
  }

  Color? menuDrawerBackgroundTop() {
    return ParseUtil.parseHexColor(style(AppStyle.menuDrawerBackgroundTop));
  }

  Color? menuDrawerBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuDrawerBackground));
  }

  Color? menuDrawerMenuIconColor() {
    return ParseUtil.parseHexColor(style(AppStyle.menuDrawerMenuIconColor));
  }

  Color? buttonBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeButtonBackground));
  }

  Color? buttonForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeButtonForeground));
  }

  Color? textButtonForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeTextButtonForeground ));
  }

  Color? outlinedButtonForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeOutlinedButtonForeground));
  }

  Color? tableFloatingButtonBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeTableFloatingButtonBackground))
      ?? buttonBackground();
  }

  Color? tableFloatingButtonForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeTableFloatingButtonForeground))
      ?? buttonForeground();
  }

  Color? listFloatingButtonBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeListFloatingButtonBackground))
        ?? buttonBackground();
  }

  Color? listFloatingButtonForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeListFloatingButtonForeground))
        ?? buttonForeground();
  }

  Color? groupHeaderBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.themeGroupHeaderBackground));
  }

  EdgeInsets? menuGridPadding() {
    return ParseUtil.parseMargins(style(AppStyle.menuGridPadding));
  }

  double? menuGridPaddingTop() {
    return ParseUtil.parseDouble(style(AppStyle.menuGridPaddingTop));
  }

  double? menuGridTileBorderRadius() {
    return ParseUtil.parseDouble(style(AppStyle.menuGridTileBorderRadius));
  }

  Color? menuGridBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridBackground));
  }

  Color? menuGridGroupTitleForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridGroupTitleForeground));
  }

  Color? menuGridGroupTitleBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridGroupTitleBackground));
  }

  Color? menuGridTileBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridTileBackground));
  }

  Color? menuGridTileForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridTileForeground));
  }

  Color? menuGridTileTitleBackground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridTileTitleBackground));
  }

  Color? menuGridTileTitleForeground() {
    return ParseUtil.parseHexColor(style(AppStyle.menuGridTileTitleForeground));
  }

}
