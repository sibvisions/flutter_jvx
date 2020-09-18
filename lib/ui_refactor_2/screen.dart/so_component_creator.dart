import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_button_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_label_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_checkbox_cell_editor_widget.dart';

import 'i_component_creator.dart';

class SoComponentCreator implements IComponentCreator {
  BuildContext context;

  Map<String, ComponentWidget Function(ChangedComponent changedComponent)>
      standardComponents = {
    'Label': (ChangedComponent changedComponent) => CoLabelWidget(
          text: null,
          componentModel: ComponentModel(changedComponent.id),
        ),
    'Panel': (ChangedComponent changedComponent) => CoPanelWidget(
          componentModel: ComponentModel(changedComponent.id),
        ),
    'Button': (ChangedComponent changedComponent) => CoButtonWidget(
          componentModel: ComponentModel(changedComponent.id),
        ),
  };

  SoComponentCreator();

  @override
  ComponentWidget createComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      if (changedComponent.className == 'Editor') {
        print('CREATING EDITOR');
      } else if (changedComponent.className == null ||
          this.standardComponents[changedComponent.className] == null) {
        componentWidget = _createDefaultComponent(changedComponent);
      } else {
        componentWidget = this
            .standardComponents[changedComponent.className](changedComponent);
      }
    }

    componentWidget.componentModel.changedComponent = changedComponent;

    if (componentWidget.componentModel.componentState is CoContainerWidgetState)
      (componentWidget.componentModel.componentState as CoContainerWidgetState)
          .layout = _createLayout(componentWidget, changedComponent);

    return componentWidget;
  }

  ComponentWidget _createDefaultComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget = CoLabelWidget(
      text: "Undefined Component '" +
          (changedComponent.className != null
              ? changedComponent.className
              : "") +
          "'!",
      componentModel: ComponentModel(changedComponent.id),
    );

    return componentWidget;
  }
}
