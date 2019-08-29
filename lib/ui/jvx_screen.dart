import 'package:flutter/material.dart';
import '../model/changed_component.dart';
import 'component/jvx_component.dart';
import 'container/jvx_container.dart';
import 'jvx_component_creater.dart';

class JVxScreen {
  Key componentId;
  Map<String, JVxComponent> components = new Map<String, JVxComponent>();
  BuildContext context;

  JVxScreen(this.componentId, List<ChangedComponent> changedComponents, this.context) {

    for(var i = 0; i < changedComponents.length; i++){
      this.addComponent(changedComponents[i], context);
    }
  }

  JVxScreen.withoutArgs();

  updateComponents(List<ChangedComponent> changedComponentsJson) {

    changedComponentsJson?.forEach((changedComponent) {
        if (components.containsKey(changedComponent.id)) {
          JVxComponent component = components[changedComponent.parent];
          component.updateProperties(changedComponent.componentProperties);
        }
    });
  }

  void addComponent(ChangedComponent component, BuildContext context) {
      JVxComponent componentClass = JVxComponentCreator.create(component, context);

      if (componentClass!= null) {
        components.putIfAbsent(component.id, () => componentClass);

        if (component.parent?.isNotEmpty ?? false) {
          JVxComponent parentComponent = components[component.parent];
          if (parentComponent!= null && parentComponent is JVxContainer) {
            componentClass.parentComponentId = Key(component.parent);
            String constraint = component.componentProperties.getProperty("constraints");
            parentComponent.addWithConstraints(componentClass, constraint);
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