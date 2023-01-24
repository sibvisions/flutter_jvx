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

enum SplitOrientation { HORIZONTAL, VERTICAL }

class FlSplitPanelModel extends FlPanelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String SCROLL_PANEL_STYLE = "f_scroll";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The initial position of the divider in the split.
  double dividerPosition = 50;

  /// The way the panels are split up.
  SplitOrientation orientation = SplitOrientation.VERTICAL;

  /// If this split panel behaves like a scroll panel
  bool get isScrollStyle => styles.contains(SCROLL_PANEL_STYLE);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlSplitPanelModel]
  FlSplitPanelModel() : super() {
    layout = "SplitLayout";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlSplitPanelModel get defaultModel => FlSplitPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    // currently ignored as its sent in pixels, which are not mobile friendly

    // Orientation
    orientation = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.orientation,
      pDefault: defaultModel.orientation,
      pCurrent: orientation,
      pConversion: orientationFromDynamic,
    );
  }

  static SplitOrientation orientationFromDynamic(dynamic pValue) {
    if (pValue != 1) {
      return SplitOrientation.HORIZONTAL;
    } else {
      return SplitOrientation.VERTICAL;
    }
  }
}
