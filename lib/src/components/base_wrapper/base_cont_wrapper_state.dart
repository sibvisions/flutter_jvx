import 'package:flutter/material.dart';

import '../../model/command/layout/register_parent_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../service/ui/i_ui_service.dart';
import '../components_factory.dart';
import 'base_comp_wrapper_state.dart';

abstract class BaseContWrapperState<T extends FlPanelModel> extends BaseCompWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// A map of all children widgets
  Map<String, Widget> children = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  affected() {
    buildChildren();
    registerParent();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Will Send [RegisterParentCommand] to [IUiService] sending its current
  /// layoutData.
  void registerParent() {
    RegisterParentCommand registerParentCommand = RegisterParentCommand(
      layoutData: layoutData.clone(),
      reason: "parent register",
    );
    uiService.sendCommand(registerParentCommand);
  }

  /// Will contact [IUiService] to get its children [FlComponentModel], will only call setState if
  /// children were either added or removed.
  bool buildChildren({bool pSetStateOnChange = true}) {
    List<FlComponentModel> models = uiService.getChildrenModels(model.id);
    Map<String, Widget> newChildrenList = {};

    bool changeDetected = false;

    // Only New Children will be used
    for (FlComponentModel model in models) {
      if (!children.containsKey(model.id)) {
        newChildrenList[model.id] = ComponentsFactory.buildWidget(model);
        changeDetected = true;
      } else {
        newChildrenList[model.id] = children[model.id]!;
      }
    }

    // Check if there are children in the old list not present in the new List
    children.forEach((key, value) {
      if (!models.any((element) => element.id == key)) {
        changeDetected = true;
      }
    });

    // Only re-render if children did change
    if (changeDetected) {
      layoutData.children.clear();
      newChildrenList.forEach((key, value) {
        layoutData.children.add(key);
      });

      children = newChildrenList;
      if (pSetStateOnChange) {
        setState(() {});
      }
    }

    return changeDetected;
  }
}
