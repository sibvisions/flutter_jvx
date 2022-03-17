import 'package:flutter_client/src/components/panel/tabset/fl_tab_panel_wrapper.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';

import 'fl_panel_model.dart';

class FlTabPanelModel extends FlPanelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If there is
  bool eventTabClosed = true;

  bool eventTabMoved = true;

  int selectedIndex = 0;

  bool draggable = false;

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

    var jsonTabPlacement = pJson[ApiObjectProperty.tabPlacement];
    if (jsonTabPlacement != null) {
      tabPlacement = TabPlacements.values[jsonTabPlacement];
    }
  }
}
