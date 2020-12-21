import 'package:flutter/material.dart';

import '../../../features/custom_screen/ui/screen/custom_screen.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/response.dart';
import '../component/co_action_component_widget.dart';
import '../component/co_checkbox_widget.dart';
import '../component/co_password_field_widget.dart';
import '../component/co_radio_button_widget.dart';
import '../component/co_text_area_widget.dart';
import '../component/co_text_field_widget.dart';
import '../component/component_widget.dart';
import '../component/models/component_model.dart';
import '../component/models/editable_component_model.dart';
import '../component/popup_menu/co_menu_item_widget.dart';
import '../component/popup_menu/co_popup_menu_button_widget.dart';
import '../component/popup_menu/co_popup_menu_widget.dart';
import '../component/popup_menu/models/popup_menu_component_model.dart';
import '../container/co_container_widget.dart';
import '../container/co_panel_widget.dart';
import '../container/container_component_model.dart';
import '../editor/celleditor/co_referenced_cell_editor_widget.dart';
import '../editor/co_editor_widget.dart';
import '../editor/editor_component_model.dart';
import 'component_model_manager.dart';
import 'so_component_creator.dart';
import 'so_data_screen.dart';
import 'so_screen_configuration.dart';

enum CoState { Added, Free, Removed, Destroyed }

class SoScreen extends StatefulWidget {
  final SoScreenConfiguration configuration;
  final SoComponentCreator creator;
  final String templateName;

  const SoScreen(
      {Key key, this.creator, @required this.configuration, this.templateName})
      : super(key: key);

  static SoScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<SoScreenState>();

  @override
  SoScreenState createState() => SoScreenState<SoScreen>();
}

class SoScreenState<T extends StatefulWidget> extends State<T>
    with SoDataScreen {
  static const HEADER_FOOTER_PANEL_COMPONENT_ID = 'headerFooterPanel';

  Map<String, ComponentWidget> _components = <String, ComponentWidget>{};
  Map<String, ComponentWidget> _additionalComponents =
      <String, ComponentWidget>{};

  ComponentModelManager _componentModelManager;

  SoComponentCreator _creator;

  bool debug = false;

  ComponentWidget rootComponent;
  ComponentWidget header;
  ComponentWidget footer;

  Map<String, ComponentWidget> get components => _components;

  @override
  void initState() {
    super.initState();

    // Init
    if ((widget as SoScreen).creator != null)
      _creator = (widget as SoScreen).creator;
    else
      _creator = SoComponentCreator();

    _componentModelManager = ComponentModelManager();
  }

  @override
  Widget build(BuildContext context) {
    SoScreenConfiguration configuration = (widget as SoScreen).configuration;

    if (configuration?.value?.closeScreenAction != null &&
        (rootComponent != null &&
            configuration?.value?.closeScreenAction?.componentId ==
                rootComponent.componentModel.name)) {
      rootComponent = null;
      _components = <String, ComponentWidget>{};
    }

    return ValueListenableBuilder(
        valueListenable: configuration,
        builder: (BuildContext context, Response response, Widget child) {
          if (response != null) {
            this.update(response);

            this.onResponse(response);

            if (rootComponent == null) {
              rootComponent = getRootComponent();
            }

            debugPrintCurrentWidgetTree();

            return FractionallySizedBox(
                widthFactor: 1, heightFactor: 1, child: rootComponent);
          } else {
            return Container();
          }
        });
  }

  void update(Response response) {
    if (response.request != null && response.responseData != null) {
      this.updateData(context, response.request, response.responseData);
    }

    if (response.responseData.screenGeneric != null) {
      if (response.responseData.screenGeneric.componentId ==
          (widget as SoScreen).configuration.componentId) {
        this.updateComponents(
            response.responseData.screenGeneric.changedComponents);
      } else if (widget is CustomScreen) {
        this.updateComponents(
            response.responseData.screenGeneric.changedComponents);
      }
    }
  }

  void updateComponents(List<ChangedComponent> changedComponents) {
    if (debug) print("ComponentScreen updateComponents: ");

    if (changedComponents != null && changedComponents.isNotEmpty) {
      changedComponents.forEach((changedComponent) {
        String parent =
            changedComponent.getProperty<String>(ComponentProperty.PARENT);

        if (changedComponent.additional ||
            (parent != null && _additionalComponents.containsKey(parent)) ||
            _additionalComponents.containsKey(changedComponent.id)) {
          _updateComponent(changedComponent, _additionalComponents);
        } else {
          _updateComponent(changedComponent, _components);
        }
      });
    }
  }

  void _updateComponent(ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    if (changedComponent != null && container != null) {
      // Checking if component already exists
      if (container.containsKey(changedComponent.id)) {
        ComponentWidget componentWidget = container[changedComponent.id];

        if (componentWidget != null && componentWidget.componentModel != null) {
          // Checking if component needs to be destroyed
          if (changedComponent.destroy) {
            if (debug) print('Destroy component (id: ${changedComponent.id})');

            _destroyComponent(componentWidget, container);
            // Checking if component needs to be removed from widget tree
          } else if (changedComponent.remove) {
            if (debug) print('Remove component (id: ${changedComponent.id})');

            _removeComponent(componentWidget, container);
          } else {
            // Moving component if component needs to be moved
            _moveComponent(componentWidget, changedComponent, container);

            if (componentWidget.componentModel.coState != CoState.Added) {
              // Adding component to widget tree
              _addComponent(changedComponent, container);
            }

            // Updating properties of component
            componentWidget.componentModel
                .updateProperties(context, changedComponent);

            if (componentWidget.componentModel?.parentComponentId != null &&
                container.containsKey(
                    componentWidget.componentModel.parentComponentId)) {
              ComponentWidget parentComponentWidget =
                  container[componentWidget.componentModel.parentComponentId];

              if (parentComponentWidget != null &&
                  parentComponentWidget is CoContainerWidget) {
                (parentComponentWidget.componentModel)
                    .updateComponentProperties(
                        context,
                        componentWidget.componentModel.componentId,
                        changedComponent);
              }
            }
          }
        } else {
          if (!changedComponent.destroy && !changedComponent.remove) {
            this._addComponent(changedComponent, container);
          }
        }
      } else {
        if (!changedComponent.destroy && !changedComponent.remove) {
          if (debug) {
            String parent =
                changedComponent.getProperty<String>(ComponentProperty.PARENT);
            print(
                'Add component (id: ${changedComponent.id}, parent: $parent, className: ${changedComponent.className})');
          }

          this._addComponent(changedComponent, container);
        } else {
          print(
              'Cannot remove or destroy component with id ${changedComponent.id}, because its not in the components list');
        }
      }
    }
  }

  /// Method for creating/adding components
  void _addComponent(ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    ComponentWidget componentWidget;

    if (changedComponent != null && container != null) {
      if (!container.containsKey(changedComponent.id)) {
        // Creating new componentModel or getting existing one
        ComponentModel componentModel =
            this._componentModelManager.addComponentModel(changedComponent);

        componentWidget = this._creator.createComponent(componentModel);

        // Updating properties of newly created component
        componentWidget.componentModel
            .updateProperties(context, changedComponent);

        if (componentWidget is CoEditorWidget) {
          // Setting data if widget is an editor
          (componentWidget.componentModel as EditorComponentModel).data = this
              .getComponentData(
                  (componentWidget.componentModel as EditorComponentModel)
                      .dataProvider);

          if (componentWidget.cellEditor is CoReferencedCellEditorWidget) {
            // If cell editor is referenced get the referenced data
            (componentWidget.cellEditor as CoReferencedCellEditorWidget)
                    .cellEditorModel
                    .referencedData =
                this.getComponentData(
                    (componentWidget.cellEditor as CoReferencedCellEditorWidget)
                        .cellEditorModel
                        .cellEditor
                        .linkReference
                        .dataProvider);
          }
        } else if (componentWidget is CoActionComponentWidget) {
          // Setting callback for all action components
          componentWidget.componentModel.onAction = this.onAction;
        } else if (_isEditableComponentWidget(componentWidget)) {
          // Setting callback for all editable components
          (componentWidget.componentModel as EditableComponentModel)
              .onComponentValueChanged = this.onComponetValueChanged;
        } else if (changedComponent.additional &&
            componentWidget is CoPopupMenuWidget) {
          // Checking if parent from popup is existing and if its a CoPopupMenuButtonWidget
          if (this._components.containsKey(
                  componentWidget.componentModel.parentComponentId) &&
              this._components[componentWidget.componentModel.parentComponentId]
                  is CoPopupMenuButtonWidget) {
            CoPopupMenuButtonWidget btn =
                _components[componentWidget.componentModel.parentComponentId];

            // Setting the popup menu of the popup button
            btn.componentModel.menu = componentWidget;
          }
        } else if (componentWidget is CoMenuItemWidget) {
          // Checking if parent of CoMenuItemWidget is CoPopupMenuWidget
          if (container.containsKey(
                  componentWidget.componentModel.parentComponentId) &&
              container[componentWidget.componentModel.parentComponentId]
                  is CoPopupMenuWidget) {
            CoPopupMenuWidget menu =
                container[componentWidget.componentModel.parentComponentId];

            // Adding/updating menu item in popup menu
            (menu.componentModel as PopupMenuComponentModel)
                .updateMenuItem(componentWidget);
          }
        }
      } else {
        componentWidget = container[changedComponent.id];

        if (componentWidget is CoEditorWidget) {
          // Setting new data
          (componentWidget.componentModel as EditorComponentModel).data = this
              .getComponentData(
                  (componentWidget.componentModel as EditorComponentModel)
                      .dataProvider);

          if (componentWidget.cellEditor is CoReferencedCellEditorWidget) {
            // Setting new referenced data
            (componentWidget.cellEditor as CoReferencedCellEditorWidget)
                .cellEditorModel
                .data = this.getComponentData((componentWidget.cellEditor
                    as CoReferencedCellEditorWidget)
                .cellEditorModel
                .cellEditor
                .linkReference
                .dataProvider);
          }
        }
      }

      if (componentWidget != null) {
        // Adding componentWidget to tree and parent
        componentWidget.componentModel.coState = CoState.Added;
        container.putIfAbsent(changedComponent.id, () => componentWidget);
        this._addToParent(componentWidget, container);
      }
    }
  }

  /// Method for adding componentWidget to parent container widget
  void _addToParent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    if (componentWidget != null &&
        componentWidget.componentModel != null &&
        componentWidget.componentModel.parentComponentId != null &&
        componentWidget.componentModel.parentComponentId.isNotEmpty) {
      ComponentWidget parentComponentWidget =
          container[componentWidget.componentModel.parentComponentId];

      // Checking if parent is CoContainerWidget and not null
      if (parentComponentWidget != null &&
          parentComponentWidget is CoContainerWidget) {
        // Adding componentWidget to parentComponentWidget with layout constraints
        (parentComponentWidget.componentModel).addWithConstraints(
            componentWidget, componentWidget.componentModel.constraints);
      }
    }
  }

  /// Method for removing components from tree
  void _removeComponent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    this._removeFromParent(componentWidget, container);
  }

  /// Method for removing components from their parents
  void _removeFromParent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    if (componentWidget != null &&
        container != null &&
        componentWidget.componentModel.parentComponentId != null &&
        componentWidget.componentModel.parentComponentId.isNotEmpty) {
      ComponentWidget parentComponentWidget =
          container[componentWidget.componentModel.parentComponentId];

      if (parentComponentWidget != null &&
          parentComponentWidget is CoContainerWidget) {
        (parentComponentWidget.componentModel)
            .removeWithComponent(componentWidget);
      }
    }
  }

  /// Method for destroying components and delete them permanently
  void _destroyComponent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    // Removing component
    this._removeComponent(componentWidget, container);

    // Destroying component
    container.remove(componentWidget.componentModel.componentId);
    componentWidget.componentModel.state = CoState.Destroyed;
  }

  /// Method for moving component
  void _moveComponent(
      ComponentWidget componentWidget,
      ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    // Getting new properties
    String parent =
        changedComponent.getProperty<String>(ComponentProperty.PARENT);
    String constraints =
        changedComponent.getProperty<String>(ComponentProperty.CONSTRAINTS);
    String layout =
        changedComponent.getProperty<String>(ComponentProperty.LAYOUT);
    String layoutData =
        changedComponent.getProperty<String>(ComponentProperty.LAYOUT_DATA);

    if (layoutData != null && layoutData.isNotEmpty) {
      if (componentWidget is CoContainerWidget) {
        if (debug) {
          print(
              'Update layoutData (id: ${changedComponent.id}, newLayoutData: $layoutData, className: ${changedComponent.className})');
        }
        // Updating layout data
        (componentWidget.componentModel)?.layout?.updateLayoutData(layoutData);
      }
    }

    if (layout != null && layout.isNotEmpty) {
      if (componentWidget is CoContainerWidget) {
        if (debug) {
          print(
              'Update layoutString (id: ${changedComponent.id}, newLayoutString: $layout, className: ${changedComponent.className})');
        }

        // Updating layout itself
        (componentWidget.componentModel)?.layout?.updateLayoutString(layout);
      }
    }

    if (parent != null &&
        parent.isNotEmpty &&
        componentWidget.componentModel.parentComponentId != parent) {
      if (debug) {
        print(
            'Move component (id: ${changedComponent.id}, oldParent: ${componentWidget.componentModel.parentComponentId}, newParent: $parent, className: ${changedComponent.className}');
      }

      // Removing component from parent
      if (componentWidget.componentModel.parentComponentId != null) {
        this._removeFromParent(componentWidget, container);
      }

      // Updating parent component id and adding it to new parent
      if (parent != null) {
        componentWidget.componentModel.parentComponentId = parent;
        this._addToParent(componentWidget, container);
      }
    }

    if (constraints != null &&
        constraints.isNotEmpty &&
        constraints != componentWidget.componentModel.constraints) {
      if (debug) {
        print(
            'Update constraints (id: ${changedComponent.id}, oldConstraints: ${componentWidget.componentModel.constraints}, newConstraints: $constraints, className: ${changedComponent.className}');
      }

      // Updating constraints on widget
      componentWidget.componentModel.constraints = constraints;

      if (componentWidget.componentModel.parentComponentId != null &&
          container
              .containsKey(componentWidget.componentModel.parentComponentId)) {
        // Getting parent
        ComponentWidget parentComponentWidget =
            container[componentWidget.componentModel.parentComponentId];

        // Updating constraints in layout
        (parentComponentWidget.componentModel as ContainerComponentModel)
            .updateConstraintsWithWidget(componentWidget, constraints);
      }
    }
  }

  ComponentWidget getRootComponent() {
    ComponentWidget rootComponent = this._components.values.firstWhere(
        (componentWidget) =>
            componentWidget.componentModel.parentComponentId == null &&
            componentWidget.componentModel.coState == CoState.Added,
        orElse: () => null);

    if (header != null || footer != null) {
      ComponentWidget headerFooterPanel = CoPanelWidget(
        componentModel: ContainerComponentModel(),
      );

      headerFooterPanel.componentModel.componentId =
          HEADER_FOOTER_PANEL_COMPONENT_ID;

      if (header != null) {
        header.componentModel.parentComponentId =
            HEADER_FOOTER_PANEL_COMPONENT_ID;
        header.componentModel.constraints = 'North';
        header.componentModel.coState = CoState.Added;
        _components[header.componentModel.componentId] = header;
      }

      if (rootComponent != null) {
        rootComponent.componentModel.parentComponentId =
            HEADER_FOOTER_PANEL_COMPONENT_ID;
        rootComponent.componentModel.constraints = 'Center';
      }

      if (footer != null) {
        footer.componentModel.parentComponentId =
            HEADER_FOOTER_PANEL_COMPONENT_ID;
        footer.componentModel.constraints = 'South';
        footer.componentModel.coState = CoState.Added;
        _components[footer.componentModel.componentId] = footer;
      }

      _components[HEADER_FOOTER_PANEL_COMPONENT_ID] = headerFooterPanel;

      (headerFooterPanel.componentModel as ContainerComponentModel)
          .addWithConstraints(header, header.componentModel.constraints);
      (headerFooterPanel.componentModel as ContainerComponentModel)
          .addWithConstraints(
              rootComponent, rootComponent.componentModel.constraints);
      (headerFooterPanel.componentModel as ContainerComponentModel)
          .addWithConstraints(footer, footer.componentModel.constraints);

      return headerFooterPanel;
    }

    return rootComponent;
  }

  /// Method for checking if widget is an editable component
  _isEditableComponentWidget(ComponentWidget componentWidget) {
    return (componentWidget is CoTextAreaWidget ||
        componentWidget is CoTextFieldWidget ||
        componentWidget is CoPasswordFieldWidget ||
        componentWidget is CoCheckBoxWidget ||
        componentWidget is CoRadioButtonWidget);
  }

  /// Method for replacing components
  ///
  /// [toReplaceComponentWidget] is the component to be replaced with [componentWidget]
  void replaceComponent(ComponentWidget componentWidget,
      ComponentWidget toReplaceComponentWidget) {
    if (componentWidget != null && toReplaceComponentWidget != null) {
      componentWidget.componentModel.parentComponentId =
          toReplaceComponentWidget.componentModel.parentComponentId;
      componentWidget.componentModel.constraints =
          toReplaceComponentWidget.componentModel.constraints;
      componentWidget.componentModel.minimumSize =
          toReplaceComponentWidget.componentModel.minimumSize;
      componentWidget.componentModel.maximumSize =
          toReplaceComponentWidget.componentModel.maximumSize;
      componentWidget.componentModel.preferredSize =
          toReplaceComponentWidget.componentModel.preferredSize;

      _removeFromParent(toReplaceComponentWidget, _components);
      _addToParent(componentWidget, _components);
    }
  }

  void onResponse(Response response) {}

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

  void debugPrintComponent(ComponentWidget component, int level) {
    if (component != null) {
      String debugString = " |" * level;
      Size size;
      //_getSizes(component.componentModel.componentId);
      String keyString = component.componentModel.componentId.toString();
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
            ((component.cellEditor?.cellEditorModel?.dataProvider != null ??
                    false)
                ? component.cellEditor.cellEditorModel.dataProvider
                : "");
      }
      if (component is CoContainerWidget) {
        debugString += ", layout: " +
            (component.componentModel.layout != null &&
                    component.componentModel.layout.rawLayoutString != null
                ? component.componentModel.layout.rawLayoutString
                : "") +
            ", layoutData: " +
            (component.componentModel.layout != null &&
                    component.componentModel.layout.rawLayoutData != null
                ? component.componentModel.layout.rawLayoutData
                : "") +
            ", childCount: " +
            (component.componentModel.components != null
                ? component.componentModel.components.length.toString()
                : "0");
        print(debugString);
        if (component.componentModel.components != null) {
          component.componentModel.components.forEach((c) {
            debugPrintComponent(c, (level + 1));
          });
        }
      } else {
        print(debugString);
      }
    }
  }

  // Size _getSizes(GlobalKey key) {
  //   if (key != null && key.currentContext != null) {
  //     final RenderBox renderBox = key.currentContext.findRenderObject();
  //     if (renderBox != null && renderBox.hasSize) {
  //       return renderBox.size;
  //     }
  //   }
  //   return null;
  // }
}
