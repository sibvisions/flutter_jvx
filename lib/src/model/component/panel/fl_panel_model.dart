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

part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

/// The model for [FlPanelWidget]
class FlPanelModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If a panel should have a default border.
  static const String STYLE_STANDARD_BORDER = "f_standard_border";

  /// If a panel should the same background color as the default editor background color.
  static const String STYLE_DEFAULT_EDITOR_BACKGROUND = "f_default_editorbackground";

  /// If a work-screen should not have a back button.
  static const String STYLE_NO_BACK = "f_no_back";

  /// If a work-screen should route to app overview on back.
  static const String STYLE_OVERVIEW_BACK = "f_overview_back";

  /// If a work-screen should have no menu.
  static const String STYLE_NO_MENU = "f_no_menu";

  /// If a work-screen should have no safe area.
  static const String STYLE_FULL_SIZE = "f_full_size";

  /// If a work-screen should have a simple menu.
  static const String STYLE_SIMPLE_MENU = "f_simple_menu";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the layout type.
  String? layout;

  /// The layout data.
  String? layoutData;

  /// The screen title.
  ///
  /// Example:
  /// "Second"
  String? screenTitle;

  /// The screen navigation name.
  ///
  /// Example:
  /// "Second"
  String? screenNavigationName;

  /// The screen class name.
  ///
  /// Example:
  /// "com.sibvisions.apps.mobile.demo.screens.features.SecondWorkScreen"
  String? screenClassName;

  /// The content title.
  String? contentTitle;

  /// If the content is modal -> Currently has no effect. Every content is modal.
  bool contentModal = true;

  /// The content class name.
  String? contentClassName;

  /// If the panel has a standard border.
  bool get hasStandardBorder => styles.contains(STYLE_STANDARD_BORDER);

  /// If the panel has the same background color as the default editor background color.
  bool get hasDefaultEditorBackground => styles.contains(STYLE_DEFAULT_EDITOR_BACKGROUND);

  /// If the screen cannot go back.
  bool get noBack => styles.contains(STYLE_NO_BACK) && !overviewBack;

  /// If the screen should route to app overview on back.
  bool get overviewBack => styles.contains(STYLE_OVERVIEW_BACK);

  /// If the screen has a drawer menu.
  bool get noMenu => styles.contains(STYLE_NO_MENU) || hasSimpleMenu;

  /// If the screen has no safe are.
  bool get fullSize => styles.contains(STYLE_FULL_SIZE);

  /// If the screen has a simple menu.
  bool get hasSimpleMenu => styles.contains(STYLE_SIMPLE_MENU);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlPanelModel]
  FlPanelModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPanelModel get defaultModel => FlPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    layout = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.layout,
      pDefault: defaultModel.layout,
      pCurrent: layout,
    );

    layoutData = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.layoutData,
      pDefault: defaultModel.layoutData,
      pCurrent: layoutData,
    );

    screenTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.screenTitle,
      pDefault: defaultModel.screenTitle,
      pCurrent: screenTitle,
    );

    screenNavigationName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.screenNavigationName,
      pDefault: defaultModel.screenNavigationName,
      pCurrent: screenNavigationName,
    );

    screenClassName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.screenClassName,
      pDefault: defaultModel.screenClassName,
      pCurrent: screenClassName,
    );

    contentTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.contentTitle,
      pDefault: defaultModel.contentTitle,
      pCurrent: contentTitle,
    );

    contentModal = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.contentModal,
      pDefault: defaultModel.contentModal,
      pCurrent: contentModal,
    );

    contentClassName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.contentClassName,
      pDefault: defaultModel.contentClassName,
      pCurrent: contentClassName,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // If the panel is a screen.
  bool get isScreen => screenClassName != null || screenNavigationName != null || screenTitle != null;

  // If the panel is a content.
  bool get isContent => contentClassName != null;

  bool get isCloseAble {
    if (overviewBack) {
      return IUiService().canRouteToAppOverview();
    }

    return !noBack;
  }
}
