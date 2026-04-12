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

class FlTabPanelModel extends FlPanelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The style name for tabs without rounded border
  static const String STYLE_TABHEADER_NOT_ROUNDED = "f_tabheader_not_rounded";

  /// The style name for scroll tabs configuration
  static const String STYLE_TABHEADER_SCROLL = "f_tabheader_scroll";

  /// The style namr for vertical tab alignment
  static const String STYLE_TAB_ALIGNMENT_VERTICAL = "f_tab_alignment_vertical";

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

  /// whether tabbar is rounded
  bool get isTabHeaderRounded => !styles.contains(STYLE_TABHEADER_NOT_ROUNDED);

  /// whether tabbar should scroll
  bool get isTabHeaderScroll => styles.contains(STYLE_TABHEADER_SCROLL);

  /// whether tab should align vertical
  bool get isTabAlignmentVertical => styles.contains(STYLE_TAB_ALIGNMENT_VERTICAL);

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
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    eventTabClosed = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventTabClosed,
      defaultValue: defaultModel.eventTabClosed,
      currentValue: eventTabClosed,
    );

    eventTabMoved = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventTabMoved,
      defaultValue: defaultModel.eventTabMoved,
      currentValue: eventTabMoved,
    );

    selectedIndex = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.selectedIndex,
      defaultValue: defaultModel.selectedIndex,
      currentValue: selectedIndex,
    );

    draggable = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.draggable,
      defaultValue: defaultModel.draggable,
      currentValue: draggable,
    );

    tabPlacement = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.tabPlacement,
      defaultValue: defaultModel.tabPlacement,
      currentValue: tabPlacement,
      conversion: (value) => TabPlacements.values[value],
    );
  }
}
