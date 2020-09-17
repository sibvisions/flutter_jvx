import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/ui_refactor/component/co_label_widget.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_widget.dart';

import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui_refactor/container/co_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor/container/container_widget.dart';

import 'i_component_creator.dart';

class SoComponentCreator implements IComponentCreator {
  BuildContext context;

  Map<String, ComponentWidget Function(ChangedComponent changedComponent)>
      standardComponents = {
    'Label': (ChangedComponent changedComponent) => ComponentWidget(
        componentModel: ComponentModel(changedComponent.id),
        child: CoLabelWidget()),
    'Panel': (ChangedComponent changedComponent) => ComponentWidget(
        componentModel: ComponentModel(changedComponent.id),
        child: CoContainerWidget(child: CoPanelWidget()))
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

    if (componentWidget.componentModel.componentState is ContainerWidgetState)
      (componentWidget.componentModel.componentState as ContainerWidgetState)
          .layout = _createLayout(componentWidget, changedComponent);

    return componentWidget;
  }

  ComponentWidget _createDefaultComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget = ComponentWidget(
        componentModel: ComponentModel(changedComponent.id),
        child: CoLabelWidget(
          text: "Undefined Component '" +
              (changedComponent.className != null
                  ? changedComponent.className
                  : "") +
              "'!",
        ));

    return componentWidget;
  }
}
