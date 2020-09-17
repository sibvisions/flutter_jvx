import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui/layout/co_border_layout.dart';
import 'package:jvx_flutterclient/ui/screen/so_data_screen.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor/container/co_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor/container/container_widget.dart';

import 'i_component_creator.dart';

class ComponentScreenWidget extends StatefulWidget {
  final IComponentCreator componentCreator;

  const ComponentScreenWidget({Key key, this.componentCreator})
      : super(key: key);

  _ComponentScreenWidgetState of() {
    return componentCreator.context
        .findAncestorStateOfType<_ComponentScreenWidgetState>();
  }

  @override
  _ComponentScreenWidgetState createState() => _ComponentScreenWidgetState();
}

class _ComponentScreenWidgetState extends State<ComponentScreenWidget>
    with SoDataScreen {
  Map<String, ComponentWidget> components = <String, ComponentWidget>{};
  Map<String, ComponentWidget> additionalComponents =
      <String, ComponentWidget>{};

  bool debug = false;
  ComponentWidget headerComponent;
  ComponentWidget footerComponent;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void updateComponents(List<ChangedComponent> changedComponents) {
    if (debug) print("ComponentScreen updateComponents:");
    changedComponents?.forEach((changedComponent) {
      String parentComponentId =
          changedComponent.getProperty<String>(ComponentProperty.PARENT, null);
      if (changedComponent.additional ||
          (parentComponentId != null &&
              additionalComponents.containsKey(parentComponentId)) ||
          additionalComponents.containsKey(changedComponent.id))
        _updateComponent(changedComponent, additionalComponents);
      else
        _updateComponent(changedComponent, components);
    });
  }

  void _updateComponent(ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    if (container.containsKey(changedComponent.id)) {
      ComponentWidget component = container[changedComponent.id];

      if (changedComponent.destroy) {
        if (debug) print("Destroy component (id:" + changedComponent.id + ")");
        _destroyComponent(component, container);
      } else if (changedComponent.remove) {
        if (debug) print("Remove component (id:" + changedComponent.id + ")");
        _removeComponent(component, container);
      } else {
        _moveComponent(component, changedComponent, container);

        if (component.componentModel.componentState.state != CoState.Added) {
          _addComponent(changedComponent, container);
        }

        component.componentModel.changedComponent = changedComponent;

        if (component.componentModel?.componentState?.parentComponentId !=
            null) {
          ComponentWidget parentComponent = container[
              component.componentModel.componentState.parentComponentId];
          if (parentComponent != null &&
              parentComponent.componentModel.componentState
                  is ContainerWidgetState) {
            (parentComponent.componentModel.componentState
                    as ContainerWidgetState)
                .updateComponentProperties(
                    component.componentModel.componentState.componentId,
                    changedComponent);
          }
        }
      }
    } else {
      if (!changedComponent.destroy && !changedComponent.remove) {
        if (debug) {
          String parent =
              changedComponent.getProperty<String>(ComponentProperty.PARENT);
          print("Add component (id:" +
              changedComponent.id +
              ",parent:" +
              (parent != null ? parent : "") +
              ", className: " +
              (changedComponent.className != null
                  ? changedComponent.className
                  : "") +
              ")");
        }
        this._addComponent(changedComponent, container);
      } else {
        print("Cannot remove or destroy component with id " +
            changedComponent.id +
            ", because its not in the components list.");
      }
    }
  }

  void _addComponent(
      ChangedComponent component, Map<String, ComponentWidget> container) {
    ComponentWidget componentClass;

    if (!container.containsKey(component.id)) {
      componentClass = widget.componentCreator.createComponent(component);

      if (componentClass.componentModel.componentState is CoEditor) {
        componentClass.componentModel.data =
            this.getComponentData(componentClass.componentModel.dataProvider);
        if (componentClass.componentModel.componentState.cellEditor
            is CoReferencedCellEditor) {
          (componentClass.componentModel.componentState.cellEditor
                  as CoReferencedCellEditor)
              .data = this.getComponentData((componentClass.componentModel
                  .componentState.cellEditor as CoReferencedCellEditor)
              .linkReference
              .dataProvider);
        }
      } else if (componentClass is CoActionComponent) {
        componentClass.componentModel.componentState.onButtonPressed =
            this.onButtonPressed;
      } else if (component.additional && componentClass is CoPopupMenu) {
        if (components.containsKey(componentClass
                .componentModel.componentState.parentComponentId) &&
            components[componentClass.componentModel.componentState
                .parentComponentId] is CoPopupMenuButton) {
          CoPopupMenuButton btn = components[
              componentClass.componentModel.componentState.parentComponentId];
          btn.menu = componentClass;
        }
      } else if (componentClass is CoMenuItem) {
        if (container.containsKey(componentClass
                .componentModel.componentState.parentComponentId) &&
            container[componentClass.componentModel.componentState
                .parentComponentId] is CoPopupMenu) {
          CoPopupMenu menu = container[
              componentClass.componentModel.componentState.parentComponentId];
          menu.updateMenuItem(componentClass);
        }
      }
    } else {
      componentClass = container[component.id];
    }

    if (componentClass != null) {
      componentClass.componentModel.componentState.state = CoState.Added;
      container.putIfAbsent(component.id, () => componentClass);
      _addToParent(componentClass, container);
    }
  }

  void _addToParent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    if (component.componentModel.componentState.parentComponentId?.isNotEmpty ??
        false) {
      ComponentWidget parentComponent =
          container[component.componentModel.componentState.parentComponentId];
      if (parentComponent != null &&
          parentComponent.componentModel.componentState
              is ContainerWidgetState) {
        (parentComponent.componentModel.componentState as ContainerWidgetState)
            .addWithConstraints(
                component, component.componentModel.componentState.constraints);
      }
    }
  }

  void _removeComponent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    _removeFromParent(component);
    component.componentModel.componentState.state = CoState.Free;
  }

  void _removeFromParent(ComponentWidget component) {
    if (component.componentModel.componentState.parentComponentId != null &&
        component.componentModel.componentState.parentComponentId.isNotEmpty) {
      ComponentWidget parentComponent =
          components[component.componentModel.componentState.parentComponentId];
      if (parentComponent != null &&
          parentComponent.componentModel.componentState
              is ContainerWidgetState) {
        (parentComponent.componentModel.componentState as ContainerWidgetState)
            ?.removeWithComponent(component);
      }
    }
  }

  void _destroyComponent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    _removeComponent(component, container);
    container.remove(component.componentModel.componentId);
    component.componentModel.componentState.state = CoState.Destroyed;
  }

  void _moveComponent(ComponentWidget component, ChangedComponent newComponent,
      Map<String, ComponentWidget> container) {
    String parent = newComponent.getProperty(ComponentProperty.PARENT);
    String constraints =
        newComponent.getProperty(ComponentProperty.CONSTRAINTS);
    String layout = newComponent.getProperty(ComponentProperty.LAYOUT);
    String layoutData = newComponent.getProperty(ComponentProperty.LAYOUT_DATA);

    if (newComponent.hasProperty(ComponentProperty.LAYOUT_DATA) &&
        layoutData != null &&
        layoutData.isNotEmpty) {
      if (component.componentModel.componentState is ContainerWidgetState)
        (component.componentModel.componentState as ContainerWidgetState)
            .layout
            ?.updateLayoutData(layoutData);
    }

    if (newComponent.hasProperty(ComponentProperty.LAYOUT) &&
        layout != null &&
        layout.isNotEmpty) {
      if (component is ContainerWidgetState)
        (component.componentModel.componentState as ContainerWidgetState)
            .layout
            ?.updateLayoutData(layoutData);
    }

    if (newComponent.hasProperty(ComponentProperty.PARENT) &&
        component.componentModel.componentState.parentComponentId != parent) {
      if (debug)
        print("Move component (id:" +
            newComponent.id +
            ",oldParent:" +
            (component.componentModel.componentState.parentComponentId != null
                ? component.componentModel.componentState.parentComponentId
                : "") +
            ",newParent:" +
            (parent != null ? parent : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.componentModel.componentState.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (parent != null) {
        component.componentModel.componentState.parentComponentId = parent;
        _addToParent(component, container);
      }
    } else if (newComponent.hasProperty(ComponentProperty.CONSTRAINTS) &&
        component.componentModel.componentState.constraints != constraints) {
      if (debug)
        print("Update constraints (id:" +
            newComponent.id +
            ",oldConstraints:" +
            (component.componentModel.componentState.constraints != null
                ? component.componentModel.componentState.constraints
                : "") +
            ",newConstraints:" +
            (constraints != null ? constraints : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.componentModel.componentState.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (constraints != null) {
        component.componentModel.componentState.constraints = constraints;
        _addToParent(component, container);
      }
    }
  }

  ComponentWidget getRootComponent() {
    ComponentWidget rootComponent = this.components.values.firstWhere(
        (element) =>
            element.componentModel.componentState.parentComponentId == null &&
            element.componentModel.componentState.state == CoState.Added,
        orElse: () => null);

    if (headerComponent != null || footerComponent != null) {
      ComponentWidget headerFooterPanel = ComponentWidget(
          componentModel: ComponentModel('headerFooterPanel'),
          child: CoPanelWidget());
      headerFooterPanel.layout = CoBorderLayout.fromLayoutString(
          headerFooterPanel, 'BorderLayout,0,0,0,0,0,0,', '');
      if (headerComponent != null) {
        headerFooterPanel.addWithConstraints(headerComponent, 'North');
      }
      headerFooterPanel.addWithConstraints(rootComponent, 'Center');
      if (footerComponent != null) {
        headerFooterPanel.addWithConstraints(footerComponent, 'South');
      }

      return headerFooterPanel;
    }

    return rootComponent;
  }

  setHeader(ComponentWidget headerComponent) {
    this.headerComponent = headerComponent;
  }

  setFooter(ComponentWidget footerComponent) {
    this.footerComponent = footerComponent;
  }

  replaceComponent(ComponentWidget compToReplace, ComponentWidget newComp) {
    if (compToReplace != null) {
      newComp.componentModel.componentState.parentComponentId =
          compToReplace.componentModel.componentState.parentComponentId;
      newComp.componentModel.componentState.constraints =
          compToReplace.componentModel.componentState.constraints;
      newComp.componentModel.componentState.minimumSize =
          compToReplace.componentModel.componentState.minimumSize;
      newComp.componentModel.componentState.maximumSize =
          compToReplace.componentModel.componentState.maximumSize;
      newComp.componentModel.componentState.preferredSize =
          compToReplace.componentModel.componentState.preferredSize;
      _removeFromParent(compToReplace);
      _addToParent(newComp, components);
    }
  }

  ComponentWidget getComponentFromName(String componentName) {
    return this.components.values.firstWhere(
        (element) =>
            element?.componentModel?.componentState?.name == componentName &&
            element?.componentModel?.componentState?.state == CoState.Added,
        orElse: () => null);
  }

  void debugPrintComponent(ComponentWidget component, int level) {
    if (component != null) {
      String debugString = " |" * level;
      Size size =
          _getSizes(component.componentModel.componentState.componentId);
      String keyString =
          component.componentModel.componentState.componentId.toString();
      keyString =
          keyString.substring(keyString.indexOf(" ") + 1, keyString.length - 1);

      debugString += " id: " +
          keyString +
          ", Name: " +
          component.componentModel.componentState.name.toString() +
          ", parent: " +
          (component.componentModel.componentState.parentComponentId != null
              ? component.componentModel.componentState.parentComponentId
              : "") +
          ", className: " +
          component.runtimeType.toString() +
          ", constraints: " +
          (component.componentModel.componentState.constraints != null
              ? component.componentModel.componentState.constraints
              : "") +
          ", size:" +
          (size != null ? size.toString() : "nosize");

      if (component is CoEditor) {
        debugString += ", dataProvider: " +
            component.componentModel.componentState.dataProvider;
      }

      if (component.componentModel.componentState is ContainerWidgetState) {
        ContainerWidgetState compState =
            component.componentModel.componentState;

        debugString += ", layout: " +
            (compState.layout != null &&
                    compState.layout.rawLayoutString != null
                ? compState.layout.rawLayoutString
                : "") +
            ", layoutData: " +
            (compState.layout != null && compState.layout.rawLayoutData != null
                ? compState.layout.rawLayoutData
                : "") +
            ", childCount: " +
            (compState.components != null
                ? compState.components.length.toString()
                : "0");
        print(debugString);

        if (compState.components != null) {
          compState.components.forEach((c) {
            debugPrintComponent(c, (level + 1));
          });
        }
      } else {
        print(debugString);
      }
    }
  }

  void debugPrintCurrentWidgetTree() {
    if (debug) {
      ComponentWidget component = getRootComponent();
      print("--------------------");
      print("Current widget tree:");
      print("--------------------");
      debugPrintComponent(component, 0);
      print("--------------------");
    }
  }

  Size _getSizes(GlobalKey key) {
    if (key != null && key.currentContext != null) {
      final RenderBox renderBox = key.currentContext.findRenderObject();
      if (renderBox != null && renderBox.hasSize) {
        return renderBox.size;
      }
    }

    return null;
  }
}
