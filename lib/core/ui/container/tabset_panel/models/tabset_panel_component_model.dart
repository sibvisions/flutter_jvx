import 'package:flutter/material.dart';

import '../../../../models/api/component/changed_component.dart';
import '../../../../models/api/component/component_properties.dart';
import '../../container_component_model.dart';

class TabsetPanelComponentModel extends ContainerComponentModel {
  bool eventTabClosed;
  bool eventTabActivated;
  bool eventTabMoved;

  List<bool> isEnabled = <bool>[];
  List<bool> isClosable = <bool>[];

  List<Tab> tabs = <Tab>[];
  List<int> pendingDeletes = <int>[];

  int selectedIndex;

  TabsetPanelComponentModel(
      {ChangedComponent changedComponent, String componentId})
      : super(changedComponent: changedComponent, componentId: componentId);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventTabClosed =
        changedComponent.getProperty<bool>(ComponentProperty.EVENT_TAB_CLOSED);
    eventTabActivated = changedComponent
        .getProperty<bool>(ComponentProperty.EVENT_TAB_ACTIVATED);
    eventTabMoved =
        changedComponent.getProperty<bool>(ComponentProperty.EVENT_TAB_MOVED);
    selectedIndex =
        changedComponent.getProperty<int>(ComponentProperty.SELECTED_INDEX);
  }
}
