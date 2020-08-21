import 'package:flutter/widgets.dart';
import '../../ui/container/co_panel.dart';
import '../../ui/layout/co_border_layout.dart';
import '../component/co_menu_item.dart';
import '../component/co_popup_menu.dart';
import '../component/co_popup_menu_button.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/i_component.dart';
import '../component/co_action_component.dart';
import '../component/component.dart';
import '../container/i_container.dart';
import '../editor/celleditor/co_referenced_cell_editor.dart';
import '../editor/co_editor.dart';
import 'so_data_screen.dart';
import 'i_component_creator.dart';

class SoComponentScreen with SoDataScreen {
  IComponentCreator _componentCreator;
  Map<String, IComponent> components = <String, IComponent>{};
  Map<String, IComponent> additionalComponents = <String, IComponent>{};
  bool debug = true;
  IComponent headerComponent;
  IComponent footerComponent;

  set context(BuildContext context) {
    super.context = context;
    _componentCreator.context = context;
  }

  get context {
    return _componentCreator.context;
  }

  SoComponentScreen(this._componentCreator);

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

  void _updateComponent(
      ChangedComponent changedComponent, Map<String, IComponent> container) {
    if (container.containsKey(changedComponent.id)) {
      IComponent component = container[changedComponent.id];

      if (changedComponent.destroy) {
        if (debug) print("Destroy component (id:" + changedComponent.id + ")");
        _destroyComponent(component, container);
      } else if (changedComponent.remove) {
        if (debug) print("Remove component (id:" + changedComponent.id + ")");
        _removeComponent(component, container);
      } else {
        _moveComponent(component, changedComponent, container);

        if (component.state != CoState.Added) {
          _addComponent(changedComponent, container);
        }

        component?.updateProperties(changedComponent);

        if (component?.parentComponentId != null) {
          IComponent parentComponent = container[component.parentComponentId];
          if (parentComponent != null && parentComponent is IContainer) {
            parentComponent.updateComponentProperties(
                component.componentId, changedComponent);
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
      ChangedComponent component, Map<String, IComponent> container) {
    Component componentClass;

    if (!container.containsKey(component.id)) {
      componentClass = _componentCreator.createComponent(component);

      if (componentClass is CoEditor) {
        componentClass.data =
            this.getComponentData(componentClass.dataProvider);
        if (componentClass.cellEditor is CoReferencedCellEditor) {
          (componentClass.cellEditor as CoReferencedCellEditor).data = this
              .getComponentData(
                  (componentClass.cellEditor as CoReferencedCellEditor)
                      .linkReference
                      .dataProvider);
        }
      } else if (componentClass is CoActionComponent) {
        componentClass.onButtonPressed = this.onButtonPressed;
      } else if (component.additional && componentClass is CoPopupMenu) {
        if (components.containsKey(componentClass.parentComponentId) &&
            components[componentClass.parentComponentId] is CoPopupMenuButton) {
          CoPopupMenuButton btn = components[componentClass.parentComponentId];
          btn.menu = componentClass;
        }
      } else if (componentClass is CoMenuItem) {
        if (container.containsKey(componentClass.parentComponentId) &&
            container[componentClass.parentComponentId] is CoPopupMenu) {
          CoPopupMenu menu = container[componentClass.parentComponentId];
          menu.updateMenuItem(componentClass);
        }
      }
    } else {
      componentClass = container[component.id];
    }

    if (componentClass != null) {
      componentClass.state = CoState.Added;
      container.putIfAbsent(component.id, () => componentClass);
      _addToParent(componentClass, container);
    }
  }

  void _addToParent(IComponent component, Map<String, IComponent> container) {
    if (component.parentComponentId?.isNotEmpty ?? false) {
      IComponent parentComponent = container[component.parentComponentId];
      if (parentComponent != null && parentComponent is IContainer) {
        parentComponent.addWithConstraints(component, component.constraints);
      }
    }
  }

  void _removeComponent(
      IComponent component, Map<String, IComponent> container) {
    _removeFromParent(component);
    component.state = CoState.Free;
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

  void _destroyComponent(
      IComponent component, Map<String, IComponent> container) {
    _removeComponent(component, container);
    container.remove(component.componentId);
    component.state = CoState.Destroyed;
  }

  void _moveComponent(IComponent component, ChangedComponent newComponent,
      Map<String, IComponent> container) {
    String parent = newComponent.getProperty(ComponentProperty.PARENT);
    String constraints =
        newComponent.getProperty(ComponentProperty.CONSTRAINTS);
    String layout = newComponent.getProperty(ComponentProperty.LAYOUT);
    String layoutData = newComponent.getProperty(ComponentProperty.LAYOUT_DATA);

    if (newComponent.hasProperty(ComponentProperty.LAYOUT_DATA) &&
        layoutData != null &&
        layoutData.isNotEmpty) {
      if (component is IContainer)
        component.layout?.updateLayoutData(layoutData);
    }

    if (newComponent.hasProperty(ComponentProperty.LAYOUT) &&
        layout != null &&
        layout.isNotEmpty) {
      if (component is IContainer) component.layout?.updateLayoutString(layout);
    }

    if (newComponent.hasProperty(ComponentProperty.PARENT) &&
        component.parentComponentId != parent) {
      if (debug)
        print("Move component (id:" +
            newComponent.id +
            ",oldParent:" +
            (component.parentComponentId != null
                ? component.parentComponentId
                : "") +
            ",newParent:" +
            (parent != null ? parent : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (parent != null) {
        component.parentComponentId = parent;
        _addToParent(component, container);
      }
    } else if (newComponent.hasProperty(ComponentProperty.CONSTRAINTS) &&
        component.constraints != constraints) {
      if (debug)
        print("Update constraints (id:" +
            newComponent.id +
            ",oldConstraints:" +
            (component.constraints != null ? component.constraints : "") +
            ",newConstraints:" +
            (constraints != null ? constraints : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (constraints != null) {
        component.constraints = constraints;
        _addToParent(component, container);
      }
    }
  }

  /// Method for getting the first component in the list (root component)
  IComponent getRootComponent() {
    IComponent rootComponent = this.components.values.firstWhere(
        (element) =>
            element.parentComponentId == null && element.state == CoState.Added,
        orElse: () => null);

    if (headerComponent != null || footerComponent != null) {
      CoPanel headerFooterPanel =
          new CoPanel(GlobalKey(debugLabel: 'headerFooterPanel'), context);
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

  setHeader(IComponent headerComponent) {
    this.headerComponent = headerComponent;
  }

  setFooter(IComponent footerComponent) {
    this.footerComponent = footerComponent;
  }

  /// Method for replacing a component with another component.
  ///
  /// Can be used for Custom Screens
  replaceComponent(IComponent compToReplace, IComponent newComp) {
    if (compToReplace != null) {
      newComp.parentComponentId = compToReplace.parentComponentId;
      newComp.constraints = compToReplace.constraints;
      newComp.minimumSize = compToReplace.minimumSize;
      newComp.maximumSize = compToReplace.maximumSize;
      newComp.preferredSize = compToReplace.preferredSize;
      _removeFromParent(compToReplace);
      _addToParent(newComp, components);
    }
  }

  /// Method for getting a component by name
  IComponent getComponentFromName(String componentName) {
    return this.components.values.firstWhere(
        (element) =>
            element?.name == componentName && element?.state == CoState.Added,
        orElse: () => null);
  }

  void debugPrintCurrentWidgetTree() {
    if (debug) {
      IComponent component = getRootComponent();
      print("--------------------");
      print("Current widget tree:");
      print("--------------------");
      debugPrintComponent(component, 0);
      print("--------------------");
    }
  }

  void debugPrintComponent(IComponent component, int level) {
    if (component != null) {
      String debugString = " |" * level;
      Size size = _getSizes(component.componentId);
      String keyString = component.componentId.toString();
      keyString =
          keyString.substring(keyString.indexOf(" ") + 1, keyString.length - 1);

      debugString += " id: " +
          keyString +
          ", Name: " +
          component.name.toString() +
          ", parent: " +
          (component.parentComponentId != null
              ? component.parentComponentId
              : "") +
          ", className: " +
          component.runtimeType.toString() +
          ", constraints: " +
          (component.constraints != null ? component.constraints : "") +
          ", size:" +
          (size != null ? size.toString() : "nosize");

      if (component is CoEditor) {
        debugString += ", dataProvider: " + component.dataProvider;
      }

      if (component is IContainer) {
        debugString += ", layout: " +
            (component.layout != null &&
                    component.layout.rawLayoutString != null
                ? component.layout.rawLayoutString
                : "") +
            ", layoutData: " +
            (component.layout != null && component.layout.rawLayoutData != null
                ? component.layout.rawLayoutData
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
