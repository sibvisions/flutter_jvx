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

import 'package:flutter/widgets.dart';

import '../../model/response/application_settings_response.dart';
import '../../util/jvx_colors.dart';
import 'app_style_direct.dart';

class AppStyle extends InheritedWidget {

  // Style properties
  static const String loginLogo = "login.logo";
  static const String loginTitle = "login.title";
  static const String loginLayout = "login.layout";
  static const String loginBackground = "login.background";
  static const String loginTopColor = "login.topColor";
  static const String loginBottomColor = "login.bottomColor";
  static const String loginColorGradient = "login.colorGradient";
  static const String loginInverseColor = "login.inverseColor";
  static const String loginBiometric = "login.biometric";
  static const String loginBiometricSecure = "login.biometric.secure";
  static const String loginBiometricMaxTimeout = "login.biometric.maxtimeout";
  static const String menuTitleColor = "menu.titleColor";
  static const String screenTitleColor = "screen.titleColor";
  static const String desktopIcon = "desktop.icon";
  static const String desktopColor = "desktop.color";
  static const String webTopMenuImage = "web.topmenu.image";
  static const String webTopMenuColor = "web.topmenu.color";
  static const String webTopMenuIconColor = "web.topmenu.iconColor";
  static const String webSideMenuColor = "web.sidemenu.color";
  static const String webSideMenuGroupColor = "web.sidemenu.groupColor";
  static const String webSideMenuTextColor = "web.sidemenu.textColor";
  static const String webSideMenuSelectionColor = "web.sidemenu.selectionColor";
  static const String opacityControls = "opacity.controls";
  static const String opacitySideMenu = "opacity.sidemenu";
  static const String opacityMenu = "opacity.menu";

  final Map<String, String>? applicationStyle;

  final ApplicationSettingsResponse applicationSettings;

  const AppStyle({
    super.key,
    required this.applicationStyle,
    required this.applicationSettings,
    required super.child,
  });

  /// The closest instance of this class that encloses the given context.
  static AppStyle of(BuildContext context) {
    final AppStyle? result = maybeOf(context);
    assert(result != null, "No AppStyle found in context");
    return result!;
  }

  /// Gets direct access
  static AppStyleDirect direct() {
    return AppStyleDirect();
  }

  /// The closest instance of this class that encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static AppStyle? maybeOf(BuildContext? context) {
    return context?.dependOnInheritedWidgetOfExactType<AppStyle>();
  }

  @override
  bool updateShouldNotify(covariant AppStyle oldWidget) =>
      applicationStyle != oldWidget.applicationStyle && applicationSettings != oldWidget.applicationSettings;

  /// Gets the style setting by name and recognizes dark mode setting
  String? style(BuildContext context, String propertyName) {
    if (!JVxColors.isLightTheme(context)) {
      String? valueDark = applicationStyle?['dark.$propertyName'];

      if (valueDark != null) {
        return valueDark;
      }
    }

    return applicationStyle?[propertyName];
  }

  /// Gets the style setting as bool
  bool styleAsBool(BuildContext context, String propertyName, [bool defaultValue = false]) {
    String? value = style(context, propertyName);

    if (value == null) {
      return defaultValue;
    }

    return bool.tryParse(value, caseSensitive: false) ?? defaultValue;
  }

}
