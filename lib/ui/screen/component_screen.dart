import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/container/i_container.dart';
import 'package:jvx_mobile_v3/ui/screen/i_component_creator.dart';

class ComponentScreen {
  IComponentCreator _componentCreator;
  Map<String, IComponent> components = <String, IComponent>{};
  bool debug = true;

  set context(BuildContext context) {
      _componentCreator.context = context;
  }
  get context {
    return _componentCreator.context;
  }

  ComponentScreen(this._componentCreator);

  void updateComponents(List<ChangedComponent> changedComponentsJson) {
    if (debug) print("JVxScreen updateComponents:");
    changedComponentsJson?.forEach((changedComponent) {
      if (components.containsKey(changedComponent.id)) {
        IComponent component = components[changedComponent.id];

        if (changedComponent.destroy) {
          if (debug)
            print("Destroy component (id:" + changedComponent.id + ")");
          _destroyComponent(component);
        } else if (changedComponent.remove) {
          if (debug) print("Remove component (id:" + changedComponent.id + ")");
          _removeComponent(component);
        } else {
          _moveComponent(component, changedComponent);

          if (component.state != JVxComponentState.Added) {
            _addComponent(changedComponent);
          }

          component?.updateProperties(changedComponent);

          if (component?.parentComponentId != null) {
            IComponent parentComponent =
                components[component.parentComponentId];
            if (parentComponent != null && parentComponent is IContainer) {
              parentComponent.updateComponentProperties(
                  component.componentId, changedComponent);
            }
          }
        }
      } else {
        if (!changedComponent.destroy && !changedComponent.remove) {
          if (debug) {
            String parent = changedComponent.getProperty<String>(ComponentProperty.PARENT);
            print("Add component (id:" + changedComponent.id + ",parent:" + (parent != null ? parent : "") +
                ", className: " + (changedComponent.className != null ? changedComponent.className : "") +
                ")");
          }
          this._addComponent(changedComponent);
        } else {
          print("Cannot remove or destroy component with id " +
              changedComponent.id +
              ", because its not in the components list.");
        }
      }
    });
  }

  void _addComponent(ChangedComponent component) {
    JVxComponent componentClass;

    if (!components.containsKey(component.id)) {
      componentClass = _componentCreator.createComponent(component);
    } else {
      componentClass = components[component.id];
    }

    if (componentClass != null) {
      componentClass.state = JVxComponentState.Added;
      components.putIfAbsent(component.id, () => componentClass);
      _addToParent(componentClass);
    }
  }

  void _addToParent(IComponent component) {
    if (component.parentComponentId?.isNotEmpty ?? false) {
      IComponent parentComponent = components[component.parentComponentId];
      if (parentComponent != null && parentComponent is IContainer) {
        parentComponent.addWithConstraints(component, component.constraints);
      }
    }
  }

  void _removeComponent(IComponent component) {
    _removeFromParent(component);
    component.state = JVxComponentState.Free;
  }

  void _removeFromParent(IComponent component) {
    if (component.parentComponentId != null &&
        component.parentComponentId.isNotEmpty) {
      IComponent parentComponent = components[component.parentComponentId];
      if (parentComponent != null && parentComponent is IContainer) {
        parentComponent?.removeWithComponent(component);
      }
    }
  }

  void _destroyComponent(IComponent component) {
    _removeComponent(component);
    components.remove(component.componentId);
    component.state = JVxComponentState.Destroyed;
  }

  void _moveComponent(IComponent component, ChangedComponent newComponent) {
    String parent = newComponent.getProperty(ComponentProperty.PARENT);
    if (component.parentComponentId != parent) {
      if (debug)
        print("Move component (id:" + newComponent.id +
            ",oldParent:" + (component.parentComponentId != null ? component.parentComponentId : "") +
            ",newParent:" + (parent != null ? parent : "") +
            ", className: " + (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (parent != null) {
        component.parentComponentId = parent;
        _addToParent(component);
      }
    }
  }

  IComponent getRootComponent() {
    return this.components.values.firstWhere((element) =>
        element.parentComponentId == null &&
        element.state == JVxComponentState.Added);
  }

  void debugPrintCurrentWidgetTree() {
    int level = 0;
    IComponent component = getRootComponent();
    print("--------------------");
    print("Current widget tree:");
    print("--------------------");
    debugPrintComponent(component, level);
    print("--------------------");
  }

  void debugPrintComponent(IComponent component, int level) {
    if (component != null) {
      String debugString = "--" * level;

      debugString += " id: " +
          component.componentId.toString() +
          ", parent: " +
          (component.parentComponentId != null
              ? component.parentComponentId
              : "") +
          ", className: " +
          component.runtimeType.toString() +
          ", constraints: " +
          (component.constraints != null ? component.constraints : "");

      if (component is IContainer) {
        debugString += ", layout: " +
            (component.layout != null
                ? component.layout.runtimeType.toString()
                : "") +
            ", childCount: " +
            (component.components != null
                ? component.components.length.toString()
                : "0");
        print(debugString);

        if (component.components != null) {
          component.components.forEach((c) {
            debugPrintComponent(c, (level + 1));
          });
        }
      } else {
        print(debugString);
      }
    }
  }
}