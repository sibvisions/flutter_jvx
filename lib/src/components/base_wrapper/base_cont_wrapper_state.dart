import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_state.dart';
import 'package:flutter_client/src/components/components_factory.dart';
import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/layout/register_parent_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

abstract class BaseContWrapperState<T extends FlPanelModel> extends BaseCompWrapperState<T> with UiServiceMixin{


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

    buildChildren();
    registerParent();
  }

  @override
  receiveNewModel({required T newModel}) {
    buildChildren();
    layoutData.layout = ILayout.getLayout(newModel.layout, newModel.layoutData);

    return super.receiveNewModel(newModel: newModel);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Will Send [RegisterParentCommand] to [IUiService] sending its current
  /// layoutData.
  void registerParent(){
    RegisterParentCommand registerParentCommand = RegisterParentCommand(
        layoutData: layoutData,
        reason: "parent register"
    );
     uiService.sendCommand(registerParentCommand);
  }


  /// Will contact [IUiService] to get its children [FlComponentModel], will only call setState if
  /// children were either added or removed.
  void buildChildren() {
    List<FlComponentModel> models = uiService.getChildrenModels(model.id);
    Map<String, Widget> newChildren = {};

    bool changeDetected = false;

    // Only New Children will be used
    for(FlComponentModel model in models){
      if(!children.containsKey(model.id)){
        newChildren[model.id] = ComponentsFactory.buildWidget(model);
        changeDetected = true;
      } else {
        newChildren[model.id] = children[model.id]!;
      }
    }

    // Check if there are children in the old list not present in the new List
    children.forEach((key, value) {
      if(!models.any((element) => element.id == key)){
        changeDetected = true;
      }
    });

    // Only re-render if children did change
    if(changeDetected){
      registerParent();
      setState(() {
        children = newChildren;
      });
    }
  }
}