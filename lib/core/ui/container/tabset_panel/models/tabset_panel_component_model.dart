import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/component/changed_component.dart';
import 'package:jvx_flutterclient/core/models/api/component/component_properties.dart';
import 'package:jvx_flutterclient/core/ui/container/container_component_model.dart';

class TabsetPanelComponentModel extends ContainerComponentModel {
  bool eventTabClosed;
  bool eventTabActivated;
  bool eventTabMoved;

  List<bool> isEnabled = <bool>[];
  List<bool> isClosable = <bool>[];

  TabController tabController;
  List<Tab> tabs = <Tab>[];
  List<int> pendingDeletes = <int>[];

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
    int indx =
        changedComponent.getProperty<int>(ComponentProperty.SELECTED_INDEX);
    tabController.animateTo(indx != null && indx >= 0 ? indx : 0);
  }
}
