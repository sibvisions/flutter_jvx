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

import '../../../components/panel/tabset/fl_tab_panel_wrapper.dart';
import '../../../service/api/shared/api_object_property.dart';
import 'fl_panel_model.dart';

class FlTabPanelModel extends FlPanelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If there is an event to close the tab.
  bool eventTabClosed = true;

  /// If there is an event on moving a tab.
  bool eventTabMoved = true;

  /// The selected index.
  int selectedIndex = 0;

  /// If the tabs are draggable.
  bool draggable = false;

  /// Placement of the tab. TOP and BOTTOM is supported.
  TabPlacements tabPlacement = TabPlacements.TOP;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlTabPanelModel]
  FlTabPanelModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTabPanelModel get defaultModel => FlTabPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    eventTabClosed = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.eventTabClosed,
      pDefault: defaultModel.eventTabClosed,
      pCurrent: eventTabClosed,
    );

    eventTabMoved = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.eventTabMoved,
      pDefault: defaultModel.eventTabMoved,
      pCurrent: eventTabMoved,
    );

    selectedIndex = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.selectedIndex,
      pDefault: defaultModel.selectedIndex,
      pCurrent: selectedIndex,
    );

    draggable = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.draggable,
      pDefault: defaultModel.draggable,
      pCurrent: draggable,
    );

    tabPlacement = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tabPlacement,
      pDefault: defaultModel.tabPlacement,
      pCurrent: tabPlacement,
      pConversion: (value) => TabPlacements.values[value],
    );
  }
}
