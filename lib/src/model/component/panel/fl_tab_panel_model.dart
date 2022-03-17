import 'package:flutter_client/src/components/panel/tabset/fl_tab_panel_wrapper.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';

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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonEventTabClosed = pJson[ApiObjectProperty.eventTabClosed];
    if (jsonEventTabClosed != null) {
      eventTabClosed = jsonEventTabClosed;
    }
    var jsonEventTabMoved = pJson[ApiObjectProperty.eventTabMoved];
    if (jsonEventTabMoved != null) {
      eventTabMoved = jsonEventTabMoved;
    }
    var jsonSelectedIndex = pJson[ApiObjectProperty.selectedIndex];
    if (jsonSelectedIndex != null) {
      selectedIndex = jsonSelectedIndex;
    }
    var jsonDraggable = pJson[ApiObjectProperty.draggable];
    if (jsonDraggable != null) {
      draggable = jsonDraggable;
    }
    var jsonTabPlacement = pJson[ApiObjectProperty.tabPlacement];
    if (jsonTabPlacement != null) {
      tabPlacement = TabPlacements.values[jsonTabPlacement];
    }
  }
}
