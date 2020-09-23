import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/response_data.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui/component/i_component.dart';
import 'package:jvx_flutterclient/ui/layout/co_border_layout.dart';
import 'package:jvx_flutterclient/ui/screen/so_data_screen.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_action_component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/container_component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/co_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/screen_model.dart';

import 'i_component_creator.dart';

class ComponentScreenWidget extends StatefulWidget {
  final IComponentCreator componentCreator;
  final Request request;
  final ResponseData responseData;

  const ComponentScreenWidget(
      {Key key, this.componentCreator, this.request, this.responseData})
      : super(key: key);

  @override
  ComponentScreenWidgetState createState() => ComponentScreenWidgetState();
}

class ComponentScreenWidgetState extends State<ComponentScreenWidget>
    with SoDataScreen {
  Map<String, ComponentWidget> components = <String, ComponentWidget>{};
  Map<String, ComponentWidget> additionalComponents =
      <String, ComponentWidget>{};

  bool debug = false;
  ComponentWidget headerComponent;
  ComponentWidget footerComponent;

  ComponentWidget rootComponent;

  @override
  Widget build(BuildContext context) {
    if (widget.request != null && widget.responseData != null)
      this.updateData(widget.request, widget.responseData);
    if (widget.responseData?.screenGeneric != null) {
      this.updateComponents(
          widget.responseData.screenGeneric.changedComponents);
      rootComponent = this.getRootComponent();
    }

    if (rootComponent != null) {
      return rootComponent;
    }
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

        if (component.componentModel.coState != CoState.Added) {
          _addComponent(changedComponent, container);
        }

        component.componentModel.changedComponent = changedComponent;

        if (component.componentModel?.parentComponentId != null) {
          ComponentWidget parentComponent =
              container[component.componentModel.parentComponentId];
          if (parentComponent != null && parentComponent is CoContainerWidget) {
            (parentComponent.componentModel as ContainerComponentModel)
                .updateComponentProperties(
                    component.componentModel.componentId, changedComponent);
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
      componentClass = widget?.componentCreator?.createComponent(component);

      if (componentClass is CoEditorWidget) {
        // CoEditorWidgetState editorWidgetState =
        //     componentClass?.componentModel?.componentState;

        componentClass?.componentModel?.data =
            this.getComponentData(componentClass?.componentModel?.dataProvider);
        /*
        if (editorWidgetState.cellEditor is CoReferencedCellEditor) {
          (editorWidgetState.cellEditor as CoReferencedCellEditor).data = this
              .getComponentData(
                  (editorWidgetState.cellEditor as CoReferencedCellEditor)
                      .linkReference
                      .dataProvider);
        }
        */
      } else if (componentClass is CoActionComponentWidget) {
        componentClass?.componentModel?.onButtonPressed = this.onButtonPressed;
      }
      /* else if (component.additional && componentClass is CoPopupMenu) {
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
      } */
    } else {
      componentClass = container[component.id];
    }

    if (componentClass != null) {
      componentClass?.componentModel?.coState = CoState.Added;
      container.putIfAbsent(component.id, () => componentClass);
      _addToParent(componentClass, container);
    }
  }

  void _addToParent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    if (component.componentModel.parentComponentId?.isNotEmpty ?? false) {
      ComponentWidget parentComponent =
          container[component.componentModel.parentComponentId];
      if (parentComponent != null && parentComponent is CoContainerWidget) {
        (parentComponent.componentModel as ContainerComponentModel)
            .addWithConstraints(
                component, component.componentModel.constraints);
      }
    }
  }

  void _removeComponent(
      ComponentWidget component, Map<String, ComponentWidget> container) {
    _removeFromParent(component);
    component.componentModel.componentState.state = CoState.Free;
  }

  void _removeFromParent(ComponentWidget component) {
    if (component.componentModel.parentComponentId != null &&
        component.componentModel.parentComponentId.isNotEmpty) {
      ComponentWidget parentComponent =
          components[component.componentModel.parentComponentId];
      if (parentComponent != null && parentComponent is CoContainerWidget) {
        (parentComponent.componentModel as ContainerComponentModel)
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
      if (component is CoContainerWidget)
        (component.componentModel as ContainerComponentModel)
            .layout
            ?.updateLayoutData(layoutData);
    }

    if (newComponent.hasProperty(ComponentProperty.LAYOUT) &&
        layout != null &&
        layout.isNotEmpty) {
      if (component is CoContainerWidget)
        (component.componentModel as ContainerComponentModel)
            .layout
            ?.updateLayoutData(layoutData);
    }

    if (newComponent.hasProperty(ComponentProperty.PARENT) &&
        component.componentModel.parentComponentId != parent) {
      if (debug)
        print("Move component (id:" +
            newComponent.id +
            ",oldParent:" +
            (component.componentModel.parentComponentId != null
                ? component.componentModel.parentComponentId
                : "") +
            ",newParent:" +
            (parent != null ? parent : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.componentModel.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (parent != null) {
        component.componentModel.parentComponentId = parent;
        _addToParent(component, container);
      }
    } else if (newComponent.hasProperty(ComponentProperty.CONSTRAINTS) &&
        component.componentModel.constraints != constraints) {
      if (debug)
        print("Update constraints (id:" +
            newComponent.id +
            ",oldConstraints:" +
            ((component.componentModel as ContainerComponentModel)
                        .constraints !=
                    null
                ? (component.componentModel as ContainerComponentModel)
                    .constraints
                : "") +
            ",newConstraints:" +
            (constraints != null ? constraints : "") +
            ", className: " +
            (newComponent.className != null ? newComponent.className : "") +
            ")");

      if (component.componentModel.parentComponentId != null) {
        _removeFromParent(component);
      }

      if (constraints != null) {
        (component.componentModel as ContainerComponentModel).constraints =
            constraints;
        _addToParent(component, container);
      }
    }
  }

  ComponentWidget getRootComponent() {
    ComponentWidget rootComponent = this.components.values.firstWhere(
        (element) =>
            element.componentModel.parentComponentId == null &&
            element.componentModel.coState == CoState.Added,
        orElse: () => null);

    /*
    if (headerComponent != null || footerComponent != null) {
      ComponentWidget headerFooterPanel =
          CoPanelWidget(componentModel: ComponentModel('headerFooterPanel'));
      (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
              .layout =
          CoBorderLayout.fromLayoutString(
              headerFooterPanel, 'BorderLayout,0,0,0,0,0,0,', '');
      if (headerComponent != null) {
        (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
            .addWithConstraints(headerComponent, 'North');
      }
      (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
          .addWithConstraints(rootComponent, 'Center');
      if (footerComponent != null) {
        (headerFooterPanel.componentModel.componentState as CoPanelWidgetState)
            .addWithConstraints(footerComponent, 'South');
      }

      return headerFooterPanel;
    }
    */

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
            element?.componentModel?.coState == CoState.Added,
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

      if (component.componentModel.componentState is CoEditorWidgetState) {
        debugString += ", dataProvider: " +
            (component.componentModel.componentState as CoEditorWidgetState)
                .dataProvider;
      }

      if (component is CoContainerWidget) {
        ContainerComponentModel comp = component.componentModel;

        debugString += ", layout: " +
            (comp.layout != null && comp.layout.rawLayoutString != null
                ? comp.layout.rawLayoutString
                : "") +
            ", layoutData: " +
            (comp.layout != null && comp.layout.rawLayoutData != null
                ? comp.layout.rawLayoutData
                : "") +
            ", childCount: " +
            (comp.components != null ? comp.components.length.toString() : "0");
        print(debugString);

        if (comp.components != null) {
          comp.components.forEach((c) {
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
