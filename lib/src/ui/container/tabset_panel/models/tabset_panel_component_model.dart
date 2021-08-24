import 'package:flutter/material.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/component_properties.dart';
import 'package:flutterclient/src/ui/container/models/container_component_model.dart';

class TabsetPanelComponentModel extends ContainerComponentModel {
  bool eventTabClosed = false;
  bool eventTabActivated = false;
  bool eventTabMoved = false;

  List<bool> isEnabled = <bool>[];
  List<bool> isClosable = <bool>[];

  List<Tab> tabs = <Tab>[];
  List<int> pendingDeletes = <int>[];

  int selectedIndex = 0;

  TabsetPanelComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  List<Widget> getTabsetComponents(BoxConstraints parentConstraints) {
    List<Widget> comp = <Widget>[];
    // components.forEach((element) {
    //   comp.add(SingleChildScrollView(
    //       child: CoScrollPanelLayout(
    //     preferredConstraints: CoScrollPanelConstraints(parentConstraints, this),
    //     container: this,
    //     children: [
    //       CoScrollPanelLayoutId(
    //           constraints: CoScrollPanelConstraints(parentConstraints, this),
    //           child: element)
    //     ],
    //   )));
    // });
    return comp;
  }

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventTabClosed = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_TAB_CLOSED, eventTabClosed)!;
    eventTabActivated = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_TAB_ACTIVATED, eventTabActivated)!;
    eventTabMoved = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_TAB_MOVED, eventTabMoved)!;
    selectedIndex = changedComponent.getProperty<int>(
        ComponentProperty.SELECTED_INDEX, selectedIndex)!;
  }
}
