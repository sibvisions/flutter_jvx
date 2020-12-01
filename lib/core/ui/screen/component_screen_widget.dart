import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/editor/editor_component_model.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/request.dart';
import '../../models/api/response.dart';
import '../../models/api/response/response_data.dart';
import '../component/component_widget.dart';
import '../component/models/action_component_model.dart';
import '../component/models/component_model.dart';
import '../component/models/editable_component_model.dart';
import '../component/popup_menu/co_menu_item_widget.dart';
import '../component/popup_menu/co_popup_menu_button_widget.dart';
import '../component/popup_menu/co_popup_menu_widget.dart';
import '../component/popup_menu/models/popup_menu_button_component_model.dart';
import '../component/popup_menu/models/popup_menu_component_model.dart';
import '../container/co_container_widget.dart';
import '../container/co_panel_widget.dart';
import '../container/container_component_model.dart';
import '../editor/celleditor/co_referenced_cell_editor_widget.dart';
import '../editor/co_editor_widget.dart';
import 'component_model_manager.dart';
import 'i_component_creator.dart';
import 'so_component_data.dart';
import 'so_data_screen.dart';

enum CoState {
  /// Component is added to the widget tree
  Added,

  /// Component is not added to the widget tree
  Free,

  /// Component was destroyed
  Destroyed
}

class ComponentScreenWidget extends StatefulWidget {
  final IComponentCreator componentCreator;
  final Response response;
  final ComponentWidget headerComponent;
  final ComponentWidget footerComponent;
  final Function(List<SoComponentData>) onData;
  final Map<String, ComponentWidget> toReplace;

  const ComponentScreenWidget(
      {Key key,
      @required this.componentCreator,
      @required this.response,
      this.headerComponent,
      this.footerComponent,
      this.onData,
      this.toReplace})
      : super(key: key);

  static ComponentScreenWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<ComponentScreenWidgetState>();

  @override
  ComponentScreenWidgetState createState() => ComponentScreenWidgetState();
}

class ComponentScreenWidgetState extends State<ComponentScreenWidget>
    with SoDataScreen {
  Map<String, ComponentWidget> components = <String, ComponentWidget>{};
  Map<String, ComponentWidget> additionalComponents =
      <String, ComponentWidget>{};

  ComponentModelManager _componentModelManager = ComponentModelManager();

  bool debug = true;

  ComponentWidget rootComponent;

  @override
  Widget build(BuildContext context) {
    if (widget.response.closeScreenAction != null &&
        (rootComponent != null &&
            rootComponent.componentModel.name ==
                widget.response.closeScreenAction.componentId)) {
      components = <String, ComponentWidget>{};
    }

    this.context = context;

    ResponseData responseData = widget.response.responseData;
    Request request = widget.response.request;

    if (request != null && responseData != null)
      this.updateData(context, request, responseData);

    if (widget.onData != null) {
      widget.onData(this.componentData);
    }
    if (responseData.screenGeneric != null) {
      this.updateComponents(responseData.screenGeneric.changedComponents);

      this.replaceComponents(widget.toReplace);

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

        component.componentModel.updateProperties(context, changedComponent);

        if (component.componentModel?.parentComponentId != null) {
          ComponentWidget parentComponent =
              container[component.componentModel.parentComponentId];
          if (parentComponent != null && parentComponent is CoContainerWidget) {
            (parentComponent.componentModel as ContainerComponentModel)
                .updateComponentProperties(context,
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
      ComponentModel componentModel =
          _componentModelManager.addComponentModel(component.id, component);

      componentClass =
          widget?.componentCreator?.createComponent(componentModel);

      componentClass.componentModel.updateProperties(context, component);

      if (componentClass is CoEditorWidget) {
        (componentClass.componentModel as EditorComponentModel).data = this
            .getComponentData(
                (componentClass.componentModel as EditorComponentModel)
                    .dataProvider);

        if (componentClass.cellEditor is CoReferencedCellEditorWidget) {
          (componentClass.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .referencedData = this.getComponentData((componentClass.cellEditor
                  as CoReferencedCellEditorWidget)
              .cellEditorModel
              .cellEditor
              .linkReference
              .dataProvider);
        }
      } else if (componentClass?.componentModel is ActionComponentModel) {
        (componentClass?.componentModel as ActionComponentModel).onAction =
            this.onAction;
      } else if (componentClass?.componentModel is EditableComponentModel) {
        (componentClass?.componentModel as EditableComponentModel)
            .onComponentValueChanged = this.onComponetValueChanged;
      } else if (component.additional && componentClass is CoPopupMenuWidget) {
        if (components
                .containsKey(componentClass.componentModel.parentComponentId) &&
            components[componentClass.componentModel.parentComponentId]
                is CoPopupMenuButtonWidget) {
          CoPopupMenuButtonWidget btn =
              components[componentClass.componentModel.parentComponentId];
          btn.componentModel.menu = componentClass;
        }
      } else if (componentClass is CoMenuItemWidget) {
        if (container
                .containsKey(componentClass.componentModel.parentComponentId) &&
            container[componentClass.componentModel.parentComponentId]
                is CoPopupMenuWidget) {
          CoPopupMenuWidget menu =
              container[componentClass.componentModel.parentComponentId];
          (menu.componentModel as PopupMenuComponentModel)
              .updateMenuItem(componentClass);
        }
      }
    } else {
      componentClass = container[component.id];

      if (componentClass is CoEditorWidget) {
        (componentClass.componentModel as EditorComponentModel).data = this
            .getComponentData(
                (componentClass.componentModel as EditorComponentModel)
                    .dataProvider);

        if (componentClass.cellEditor is CoReferencedCellEditorWidget) {
          (componentClass.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .data = this.getComponentData((componentClass.cellEditor
                  as CoReferencedCellEditorWidget)
              .cellEditorModel
              .cellEditor
              .linkReference
              .dataProvider);
        }
      }
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
    component.componentModel.state = CoState.Destroyed;
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
      if (component is CoContainerWidget) {
          (component.componentModel as ContainerComponentModel)
              .layout
              .updateLayoutData(layoutData);
      }
    }

    if (newComponent.hasProperty(ComponentProperty.LAYOUT) &&
        layout != null &&
        layout.isNotEmpty) {
      if (component is CoContainerWidget) {
          (component.componentModel as ContainerComponentModel)
              .layout
              .updateLayoutData(layoutData);
      }
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
            (component.componentModel.constraints != null
                ? component.componentModel.constraints
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
        component.componentModel.constraints = constraints;
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

    if (widget.headerComponent != null || widget.footerComponent != null) {
      ComponentWidget headerFooterPanel =
          CoPanelWidget(componentModel: ContainerComponentModel());

      headerFooterPanel.componentModel.componentId = 'headerFooterPanel';

      if (widget.headerComponent != null) {
        widget.headerComponent.componentModel.parentComponentId =
            'headerFooterPanel';
        widget.headerComponent.componentModel.constraints = 'North';
        widget.headerComponent.componentModel.coState = CoState.Added;
      }

      if (rootComponent != null) {
        rootComponent.componentModel.parentComponentId = 'headerFooterPanel';
        rootComponent.componentModel.constraints = 'Center';
      }

      if (widget.footerComponent != null) {
        widget.footerComponent.componentModel.parentComponentId =
            'headerFooterPanel';
        widget.footerComponent.componentModel.constraints = 'South';
        widget.footerComponent.componentModel.coState = CoState.Added;
      }

      components[widget.headerComponent.componentModel.componentId] =
          widget.headerComponent;
      components[widget.footerComponent.componentModel.componentId] =
          widget.footerComponent;
      components[headerFooterPanel.componentModel.componentId] =
          headerFooterPanel;

      return headerFooterPanel;
    }

    return rootComponent;
  }

  replaceComponent(ComponentWidget compToReplace, ComponentWidget newComp) {
    if (compToReplace != null) {
      newComp.componentModel.parentComponentId =
          compToReplace.componentModel.parentComponentId;
      newComp.componentModel.constraints =
          compToReplace.componentModel.constraints;
      newComp.componentModel.minimumSize =
          compToReplace.componentModel.minimumSize;
      newComp.componentModel.maximumSize =
          compToReplace.componentModel.maximumSize;
      newComp.componentModel.preferredSize =
          compToReplace.componentModel.preferredSize;
      _removeFromParent(compToReplace);
      _addToParent(newComp, components);
    }
  }

  ComponentWidget getComponentFromName(String componentName) {
    return this.components.values.firstWhere(
        (element) =>
            element?.componentModel?.name == componentName &&
            element?.componentModel?.coState == CoState.Added,
        orElse: () => null);
  }

  void debugPrintComponent(ComponentWidget component, int level) {
    if (component != null) {
      String debugString = " |" * level;
      Size size = _getSizes(component.key);
      String keyString = component.key.toString();
      keyString =
          keyString.substring(keyString.indexOf(" ") + 1, keyString.length - 1);

      debugString += " id: " +
          keyString +
          ", Name: " +
          component.componentModel.name.toString() +
          ", parent: " +
          (component.componentModel.parentComponentId != null
              ? component.componentModel.parentComponentId
              : "") +
          ", className: " +
          component.runtimeType.toString() +
          ", constraints: " +
          (component.componentModel.constraints != null
              ? component.componentModel.constraints
              : "") +
          ", size:" +
          (size != null ? size.toString() : "nosize");

      if (component is CoEditorWidget) {
        debugString += ", dataProvider: " +
            (component.componentModel as EditorComponentModel).dataProvider;
      }

      if (component is CoContainerWidget) {
        debugString += ", layout: " +
            ((component.componentModel as ContainerComponentModel).layout !=
                        null &&
                    (component.componentModel as ContainerComponentModel)
                            .layout
                            .rawLayoutString !=
                        null
                ? (component.componentModel as ContainerComponentModel)
                    .layout
                    .rawLayoutString
                : "") +
            ", layoutData: " +
            ((component.componentModel as ContainerComponentModel).layout !=
                        null &&
                    (component.componentModel as ContainerComponentModel)
                            .layout
                            .rawLayoutData !=
                        null
                ? (component.componentModel as ContainerComponentModel)
                    .layout
                    .rawLayoutData
                : "") +
            ", childCount: " +
            ((component.componentModel as ContainerComponentModel).components !=
                    null
                ? (component.componentModel as ContainerComponentModel)
                    .components
                    .length
                    .toString()
                : "0");
        print(debugString);

        if ((component.componentModel as ContainerComponentModel).components !=
            null) {
          (component.componentModel as ContainerComponentModel)
              .components
              .forEach((c) {
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

  List<ComponentWidget> getChildren(String componentId) {
    if (!this.components.containsKey(componentId)) {
      return null;
    }

    List<ComponentWidget> children = <ComponentWidget>[];

    this.components.forEach((key, value) {
      if (value.componentModel.parentComponentId == componentId &&
          value.componentModel.coState == CoState.Added) {
        children.add(value);
      }
    });

    return children;
  }

  void replaceComponents(Map<String, ComponentWidget> toReplaceComponents) {
    if (toReplaceComponents == null || toReplaceComponents.isEmpty) return;

    toReplaceComponents.forEach((name, toReplaceComponent) {
      ComponentWidget component = this.getComponentFromName(name);

      if (component != null && component != toReplaceComponent) {
        toReplaceComponent.componentModel.updateProperties(
            context, component.componentModel.changedComponent);
        toReplaceComponent.componentModel.componentId =
            component.componentModel.componentId;
        toReplaceComponent.componentModel.parentComponentId =
            component.componentModel.parentComponentId;
        toReplaceComponent.componentModel.constraints =
            component.componentModel.constraints;
        toReplaceComponent.componentModel.minimumSize =
            component.componentModel.minimumSize;
        toReplaceComponent.componentModel.maximumSize =
            component.componentModel.maximumSize;
        toReplaceComponent.componentModel.preferredSize =
            component.componentModel.preferredSize;

        _removeFromParent(component);
        components[toReplaceComponent.componentModel.componentId] =
            toReplaceComponent;
      }
    });
  }
}
