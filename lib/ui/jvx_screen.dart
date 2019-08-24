import 'package:flutter/material.dart';
import '../model/changed_component.dart';
import 'component/jvx_component.dart';
import 'container/jvx_container.dart';
import 'jvx_component_creater.dart';

class JVxScreen {
  Key componentId;
  Map<String, JVxComponent> components = new Map<String, JVxComponent>();

  JVxScreen(this.componentId, List<ChangedComponent> changedComponents) {

    for(var i = 0; i < changedComponents.length; i++){
      this.addComponent(changedComponents[i]);
    }
  }

  updateComponents(List<ChangedComponent> changedComponentsJson) {

  }

  void addComponent(ChangedComponent component) {
      JVxComponent componentClass = JVxComponentCreator.create(component);

      if (componentClass!= null) {
        components.putIfAbsent(component.id, () => componentClass);

        if (component.parent?.isNotEmpty ?? false) {
          JVxComponent parentComponent = components[component.parent];
          if (parentComponent!= null && parentComponent is JVxContainer) {
            componentClass.parentComponentId = Key(component.parent);
            parentComponent.addWithConstraints(componentClass, component.constraint);
          }
        }
      }
  }

  JVxComponent getRootComponent() {
    return this.components.values.firstWhere((element) => element.parentComponentId==null);
  }

  Widget getWidget() {
    JVxComponent component = this.getRootComponent();

    if (component!= null) {
      return component.getWidget();
    } else {
      // ToDO
      return Container(
        alignment: Alignment.center,
        child: Text('Test'),
      );
    }
  }
}