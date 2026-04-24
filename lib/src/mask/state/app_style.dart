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
import '../../service/config/i_config_service.dart';
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

  //Themes
  static const String themeColor = "theme.color";
  static const String themeTextButtonForeground = "theme.data.textbutton.foreground";
  static const String themeOutlinedButtonForeground = "theme.data.outlinedbutton.foreground";
  static const String themeGroupHeaderBackground = "theme.data.group.header.background";

  static const String themeBorderRadius = "theme.data.borderRadius";
  static const String themeEditorBorderRadius = "theme.data.editor.borderRadius";
  static const String themePopupMenuBorderRadius = "theme.data.popupmenu.borderRadius";
  static const String themePanelBorderRadius = "theme.data.panel.borderRadius";
  static const String themeDialogBorderRadius = "theme.data.dialog.borderRadius";

  static const String themeTableBorderRadius = "theme.data.table.borderRadius";
  static const String themeTableFloatingButtonBackground = "theme.data.table.floatingbutton.background";
  static const String themeTableFloatingButtonForeground = "theme.data.table.floatingbutton.foreground";

  static const String themeListBorderRadius = "theme.data.list.borderRadius";
  static const String themeListCardBorderRadius = "theme.data.list.card.borderRadius";
  static const String themeListFloatingButtonBackground = "theme.data.list.floatingbutton.background";
  static const String themeListFloatingButtonForeground = "theme.data.list.floatingbutton.foreground";

  static const String themeSlideButtonBorderRadius = "theme.data.slidebutton.borderRadius";
  static const String themeSlideButtonHandleRadius = "theme.data.slidebutton.handleRadius";

  static const String themeButtonBorderRadius = "theme.data.button.borderRadius";
  static const String themeButtonGroupBorderRadius = "theme.data.buttongroup.borderRadius";
  static const String themeButtonBackground = "theme.data.button.background";
  static const String themeButtonForeground = "theme.data.button.foreground";

  static const String menuDrawerBackground = "theme.data.drawer.background";
  static const String menuDrawerBackgroundTop = "theme.data.drawer.backgroundTop";
  static const String menuDrawerMenuIconColor = "theme.data.drawer.menuIconColor";
  static const String menuDrawerCompactHeader = "theme.data.drawer.compactHeader";
  static const String menuDrawerCompactFooter = "theme.data.drawer.compactFooter";

  static const String menuGridBackground = "theme.data.gridMenu.background";
  static const String menuGridPadding = "theme.data.gridMenu.padding";
  static const String menuGridPaddingTop = "theme.data.gridMenu.paddingTop";
  static const String menuGridTileBorderRadius = "theme.data.gridMenu.tileBorderRadius";
  static const String menuGridTileBackground = "theme.data.gridMenu.tileBackground";
  static const String menuGridTileForeground = "theme.data.gridMenu.tileForeground";
  static const String menuGridTileTitleBackground = "theme.data.gridMenu.tileTitleBackground";
  static const String menuGridTileTitleForeground = "theme.data.gridMenu.tileTitleForeground";
  static const String menuGridGroupTitleBackground = "theme.data.gridMenu.groupTitleBackground";
  static const String menuGridGroupTitleForeground = "theme.data.gridMenu.groupTitleForeground";

  final AppStyleDirect direct;

  final ApplicationSettingsResponse applicationSettings;

  final bool darkMode;

  AppStyle({
    super.key,
    Map<String, String>? applicationStyle,
    required this.applicationSettings,
    this.darkMode = false,
    required super.child,
  }) : direct = AppStyleDirect(applicationStyle, darkMode: darkMode);

  /// The closest instance of this class that encloses the given context.
  static AppStyle of(BuildContext context) {
    final AppStyle? result = maybeOf(context);
    assert(result != null, "No AppStyle found in context");
    return result!;
  }

  static AppStyleDirect directOf(BuildContext context) {
    final AppStyle? result = maybeOf(context);
    assert(result != null, "No AppStyle found in context");
    return result!.direct;
  }

  /// Gets direct access from configuration style
  static AppStyleDirect directFromConfig() {
    return AppStyleDirect(IConfigService().applicationStyle.value);
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
      !direct.isSame(oldWidget.direct) && applicationSettings != oldWidget.applicationSettings;

}
