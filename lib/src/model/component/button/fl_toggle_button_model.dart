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

/// The model for [FlToggleButtonWidget]
class FlToggleButtonModel extends FlButtonModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If the button is selected;
  bool selected = false;

  /// If the button is selected (aria label)
  bool ariaPressed = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlToggleButtonModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlToggleButtonModel get defaultModel => FlToggleButtonModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    selected = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.selected,
      pDefault: defaultModel.selected,
      pCurrent: selected,
    );
    ariaPressed = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.ariaPressed,
      pDefault: defaultModel.ariaPressed,
      pCurrent: ariaPressed,
    );
  }
}
