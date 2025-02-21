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

class FlGroupPanelModel extends FlPanelModel implements FlLabelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The style name for flat group panel
  static const String STYLE_FLAT = "f_panel_flat";

  /// The style name for no border
  static const String STYLE_NO_BORDER = "f_panel_noborder";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The text shown in the [FlGroupPanelWrapper]
  @override
  String text = "";

  bool get isFlatStyle => styles.contains(STYLE_FLAT);

  bool get isBorderHidden => styles.contains(STYLE_NO_BORDER);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlGroupPanelModel]
  FlGroupPanelModel() : super() {
    horizontalAlignment = HorizontalAlignment.STRETCH;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlGroupPanelModel get defaultModel => FlGroupPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    text = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.text,
      pDefault: defaultModel.text,
      pCurrent: text,
    );
  }
}
