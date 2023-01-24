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
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the layout type.
  String? layout;

  /// The layout data.
  String? layoutData;

  /// The screen title.
  String? screenTitle;

  /// The screen class name.
  String? screenClassName;

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

    screenClassName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.screenClassName,
      pDefault: defaultModel.screenClassName,
      pCurrent: screenClassName,
    );
  }
}
