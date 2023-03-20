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

  /// If a panel should have a default 1px border with [JVxColors.COMPONENT_DISABLED_LIGHTER] color.
  static const String STANDARD_BORDER_STYLE = "f_standard_border";

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

  bool get hasStandardBorder => styles.contains(STANDARD_BORDER_STYLE);
}
