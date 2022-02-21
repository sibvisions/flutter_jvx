import 'package:flutter/material.dart';
import 'base_comp_wrapper_state.dart';
import '../components_factory.dart';
import '../../layout/i_layout.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/layout/register_parent_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../service/ui/i_ui_service.dart';

abstract class BaseContWrapperState<T extends FlPanelModel> extends BaseCompWrapperState<T> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// A map of all children widgets
  Map<String, Widget> children = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.layout = ILayout.getLayout(model.layout, model.layoutData);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();

    registerParent();
    buildChildren();
  }

  @override
  receiveNewModel({required T newModel}) {
    layoutData.layout = ILayout.getLayout(newModel.layout, newModel.layoutData);
    super.receiveNewModel(newModel: newModel);

    buildChildren();
    registerParent();
  }

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
    RegisterParentCommand registerParentCommand =
        RegisterParentCommand(layoutData: layoutData.clone(), reason: "parent register");
    uiService.sendCommand(registerParentCommand);
  }

  /// Will contact [IUiService] to get its children [FlComponentModel], will only call setState if
  /// children were either added or removed.
  void buildChildren() {
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
      setState(() {
        children = newChildrenList;
      });
    }
  }
}
