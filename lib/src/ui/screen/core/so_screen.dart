import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/requests/press_button_request.dart';
import 'package:flutterclient/src/ui/component/popup_menu/co_menu_item_widget.dart';
import 'package:flutterclient/src/ui/component/popup_menu/co_popup_menu_button_widget.dart';
import 'package:flutterclient/src/ui/component/popup_menu/co_popup_menu_widget.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/popup_menu_component_model.dart';
import 'package:flutterclient/src/ui/container/co_panel_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/api/response_objects/close_screen_action_response_object.dart';
import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component.dart';
import '../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/color/color_extension.dart';
import '../../component/component_widget.dart';
import '../../component/model/component_model.dart';
import '../../container/co_container_widget.dart';
import '../../container/models/container_component_model.dart';
import '../../editor/cell_editor/co_referenced_cell_editor_widget.dart';
import '../../editor/co_editor_widget.dart';
import '../../editor/editor_component_model.dart';
import 'configuration/so_screen_configuration.dart';
import 'manager/component_model_manager.dart';
import 'so_component_creator.dart';
import 'so_data_screen.dart';

enum CoState { Added, Free, Removed, Destroyed }

class SoScreen extends StatefulWidget {
  final SoScreenConfiguration configuration;
  final SoComponentCreator creator;

  SoScreen({
    Key? key,
    required this.configuration,
    required this.creator,
  }) : super(key: key);

  static SoScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<SoScreenState>();

  @override
  SoScreenState createState() => SoScreenState<SoScreen>();
}

class SoScreenState<T extends SoScreen> extends State<T> with SoDataScreen {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static const HEADER_FOOTER_PANEL_COMPONENT_ID = 'headerFooterPanel';

  Map<String, ComponentWidget> _components = <String, ComponentWidget>{};
  Map<String, ComponentWidget> _additionalComponents =
      <String, ComponentWidget>{};

  ComponentWidget? rootComponent;
  ComponentWidget? header;
  ComponentWidget? footer;

  ComponentModelManager _componentModelManager = ComponentModelManager();

  Map<String, ComponentWidget> get components => _components;

  void onState(ApiState? state) {
    if (state is ApiResponse && widget.configuration.withServer) {
      _checkForCloseScreenAction(state);

      setState(() {
        update(state);
      });

      rootComponent = getRootComponent();
    }
  }

  void _checkForCloseScreenAction(ApiResponse response) {
    if (response.hasObject<CloseScreenActionResponseObject>()) {
      CloseScreenActionResponseObject closeScreenAction =
          response.getObjectByType<CloseScreenActionResponseObject>()!;

      if (closeScreenAction.componentId ==
          rootComponent?.componentModel.componentId) {
        rootComponent = null;
        _components = <String, ComponentWidget>{};
      }
    }
  }

  void update(ApiResponse response) {
    if (_isOfflineRequest(response)) {
      goOffline(context, response);
    } else if (response.hasDataObject) {
      updateData(context, response.request, response.getAllDataObjects());
    }

    ScreenGenericResponseObject? screenGeneric =
        response.getObjectByType<ScreenGenericResponseObject>();

    if (screenGeneric != null) {
      if (screenGeneric.componentId == widget.configuration.componentId) {
        updateComponents(screenGeneric.changedComponents);
      }
    }
  }

  void updateComponents(List<ChangedComponent> changedComponents) {
    if (changedComponents.isNotEmpty) {
      for (final changedComponent in changedComponents) {
        String? parent = changedComponent.getProperty<String>(
            ComponentProperty.PARENT, null);

        if (changedComponent.additional ||
            (parent != null &&
                parent.isNotEmpty &&
                _additionalComponents.containsKey(parent)) ||
            _additionalComponents.containsKey(changedComponent.id)) {
          _updateComponent(changedComponent, _additionalComponents);
        } else {
          _updateComponent(changedComponent, _components);
        }
      }
    }
  }

  void _updateComponent(ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    if (container.containsKey(changedComponent.id)) {
      ComponentWidget componentWidget = container[changedComponent.id]!;

      if (changedComponent.destroy ?? false) {
        _destroyComponent(componentWidget, container);
      } else if (changedComponent.remove ?? false) {
        _removeComponent(componentWidget, container);
      } else {
        _moveComponent(componentWidget, changedComponent, container);

        if (componentWidget.componentModel.state != CoState.Added) {
          _addComponent(changedComponent, container);
        }

        componentWidget.componentModel
            .updateProperties(context, changedComponent);

        if (componentWidget.componentModel.parentComponentId != null &&
            container.containsKey(
                componentWidget.componentModel.parentComponentId)) {
          ComponentWidget parentComponentWidget =
              container[componentWidget.componentModel.parentComponentId]!;

          if (parentComponentWidget is CoContainerWidget) {
            (parentComponentWidget.componentModel as ContainerComponentModel)
                .updateComponentProperties(
                    context,
                    componentWidget.componentModel.componentId!,
                    changedComponent);
          }
        }
      }
    } else {
      if (changedComponent.destroy != null &&
          !changedComponent.destroy! &&
          changedComponent.remove != null &&
          !changedComponent.remove!) {
        _addComponent(changedComponent, container);
      }
    }
  }

  void _addComponent(ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    late ComponentWidget componentWidget;

    if (!container.containsKey(changedComponent.id)) {
      ComponentModel componentModel = _componentModelManager.addComponentModel(
          changedComponent,
          onAction: onAction,
          onComponentValueChanged: onComponentValueChanged)!;

      componentWidget = widget.creator.createComponent(componentModel);

      componentWidget.componentModel
          .updateProperties(context, changedComponent);

      if (componentWidget is CoEditorWidget) {
        (componentWidget.componentModel as EditorComponentModel).data =
            getComponentData(
                (componentWidget.componentModel as EditorComponentModel)
                    .dataProvider!);

        if (componentWidget.cellEditor is CoReferencedCellEditorWidget) {
          (componentWidget.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .referencedData = getComponentData((componentWidget.cellEditor
                  as CoReferencedCellEditorWidget)
              .cellEditorModel
              .cellEditor
              .linkReference!
              .dataProvider!);
        }
      } else if (changedComponent.additional &&
          componentWidget is CoPopupMenuWidget) {
        if (_components.containsKey(
                componentWidget.componentModel.parentComponentId) &&
            _components[componentWidget.componentModel.parentComponentId]
                is CoPopupMenuButtonWidget) {
          CoPopupMenuButtonWidget btn =
              _components[componentWidget.componentModel.parentComponentId]!
                  as CoPopupMenuButtonWidget;

          btn.componentModel.menu = componentWidget;
        }
      } else if (componentWidget is CoMenuItemWidget) {
        if (container.containsKey(
                componentWidget.componentModel.parentComponentId) &&
            container[componentWidget.componentModel.parentComponentId]
                is CoPopupMenuWidget) {
          CoPopupMenuWidget menu =
              container[componentWidget.componentModel.parentComponentId]!
                  as CoPopupMenuWidget;

          (menu.componentModel as PopupMenuComponentModel)
              .updateMenuItem(componentWidget);
        }
      }
    } else {
      componentWidget = container[changedComponent.id]!;

      if (componentWidget is CoEditorWidget) {
        (componentWidget.componentModel as EditorComponentModel).data =
            getComponentData(
                (componentWidget.componentModel as EditorComponentModel)
                    .dataProvider!);

        if (componentWidget.cellEditor is CoReferencedCellEditorWidget) {
          (componentWidget.cellEditor as CoReferencedCellEditorWidget)
              .cellEditorModel
              .referencedData = getComponentData((componentWidget.cellEditor
                  as CoReferencedCellEditorWidget)
              .cellEditorModel
              .cellEditor
              .linkReference!
              .dataProvider!);
        }
      }
    }

    componentWidget.componentModel.state = CoState.Added;
    container.putIfAbsent(changedComponent.id!, () => componentWidget);
    _addToParent(componentWidget, container);
  }

  void _addToParent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    if (componentWidget.componentModel.parentComponentId != null &&
        componentWidget.componentModel.parentComponentId!.isNotEmpty) {
      ComponentWidget? parentComponentWidget =
          container[componentWidget.componentModel.parentComponentId];

      if (parentComponentWidget != null &&
          parentComponentWidget is CoContainerWidget) {
        (parentComponentWidget.componentModel as ContainerComponentModel)
            .addWithConstraints(
                componentWidget, componentWidget.componentModel.constraints!);
      }
    }
  }

  void _destroyComponent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    _removeComponent(componentWidget, container);

    container.remove(componentWidget.componentModel.componentId);
    componentWidget.componentModel.state = CoState.Destroyed;
  }

  void _removeComponent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    _removeFromParent(componentWidget, container);
  }

  void _removeFromParent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    if (componentWidget.componentModel.parentComponentId != null &&
        componentWidget.componentModel.parentComponentId!.isNotEmpty) {
      ComponentWidget? parentComponentWidget =
          container[componentWidget.componentModel.parentComponentId];

      if (parentComponentWidget != null &&
          parentComponentWidget is CoContainerWidget) {
        (parentComponentWidget.componentModel as ContainerComponentModel)
            .removeWithComponent(componentWidget);
      }
    }
  }

  void _moveComponent(
      ComponentWidget componentWidget,
      ChangedComponent changedComponent,
      Map<String, ComponentWidget> container) {
    String? parent =
        changedComponent.getProperty<String>(ComponentProperty.PARENT, null);
    String? constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, null);
    String? layout =
        changedComponent.getProperty<String>(ComponentProperty.LAYOUT, null);
    String? layoutData = changedComponent.getProperty<String>(
        ComponentProperty.LAYOUT_DATA, null);

    if (componentWidget is CoContainerWidget) {
      if (layoutData != null && layoutData.isNotEmpty) {
        (componentWidget.componentModel as ContainerComponentModel)
            .layout
            ?.updateLayoutData(layoutData);
      }

      if (layout != null && layout.isNotEmpty) {
        (componentWidget.componentModel as ContainerComponentModel)
            .layout
            ?.updateLayoutString(layout);
      }
    }

    if (parent != null &&
        parent.isNotEmpty &&
        componentWidget.componentModel.parentComponentId != parent) {
      if (componentWidget.componentModel.parentComponentId != null) {
        _removeFromParent(componentWidget, container);
      }

      componentWidget.componentModel.parentComponentId = parent;
      _addToParent(componentWidget, container);
    }

    if (constraints != null &&
        constraints.isNotEmpty &&
        constraints != componentWidget.componentModel.constraints) {
      componentWidget.componentModel.constraints = constraints;

      if (componentWidget.componentModel.parentComponentId != null &&
          container
              .containsKey(componentWidget.componentModel.parentComponentId)) {
        ComponentWidget parentComponentWidget =
            container[componentWidget.componentModel.parentComponentId]!;

        (parentComponentWidget.componentModel as ContainerComponentModel)
            .updateConstraintsWithWidget(componentWidget, constraints);
      }
    }
  }

  ComponentWidget? getRootComponent() {
    ComponentWidget? rootComponent;
    try {
      rootComponent = _components.values.firstWhere(
        (componentWidget) =>
            componentWidget.componentModel.parentComponentId == null &&
            componentWidget.componentModel.state == CoState.Added,
      );
    } catch (e) {
      rootComponent = null;
    }

    if (header != null || footer != null) {
      ComponentWidget headerFooterPanel = CoPanelWidget(
        componentModel:
            ContainerComponentModel(changedComponent: ChangedComponent()),
      );

      headerFooterPanel.componentModel.componentId =
          HEADER_FOOTER_PANEL_COMPONENT_ID;

      if (header != null) {
        header!.componentModel.parentComponentId =
            HEADER_FOOTER_PANEL_COMPONENT_ID;
        header!.componentModel.constraints = 'North';
        header!.componentModel.state = CoState.Added;
        _components[header!.componentModel.componentId!] = header!;
      }

      if (rootComponent != null) {
        rootComponent.componentModel.parentComponentId =
            HEADER_FOOTER_PANEL_COMPONENT_ID;
        rootComponent.componentModel.constraints = 'Center';
      }

      if (footer != null) {
        footer!.componentModel.parentComponentId =
            HEADER_FOOTER_PANEL_COMPONENT_ID;
        footer!.componentModel.constraints = 'South';
        footer!.componentModel.state = CoState.Added;
        _components[footer!.componentModel.componentId!] = footer!;
      }

      _components[HEADER_FOOTER_PANEL_COMPONENT_ID] = headerFooterPanel;

      if (rootComponent != null) {
        (headerFooterPanel.componentModel as ContainerComponentModel)
            .addWithConstraints(header!, header!.componentModel.constraints!);
        (headerFooterPanel.componentModel as ContainerComponentModel)
            .addWithConstraints(
                rootComponent, rootComponent.componentModel.constraints!);
        (headerFooterPanel.componentModel as ContainerComponentModel)
            .addWithConstraints(footer!, footer!.componentModel.constraints!);
      }

      return headerFooterPanel;
    }

    return rootComponent;
  }

  /// Method for replacing components
  ///
  /// [toReplaceComponentWidget] is the component to be replaced with [componentWidget]
  void replaceComponent(ComponentWidget componentWidget,
      ComponentWidget toReplaceComponentWidget) {
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

  bool _isOfflineRequest(ApiResponse response) {
    if (response.request is PressButtonRequest &&
        (response.request as PressButtonRequest).classNameEventSourceRef !=
            null &&
        (response.request as PressButtonRequest).classNameEventSourceRef ==
            'OfflineButton') {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    onState(widget.configuration.value);

    widget.configuration.addListener(() => onState(widget.configuration.value));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.configuration
        .removeListener(() => onState(widget.configuration.value));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: !kIsWeb
          ? AppBar(
              actionsIconTheme: IconThemeData(
                  color: Theme.of(context).primaryColor.textColor()),
              title: Text(
                '${widget.configuration.screenTitle}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor.textColor()),
              ),
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor.textColor(),
                  ),
                  onPressed: () {
                    widget.configuration
                        .onPopPage!(widget.configuration.componentId);
                  }),
              actions: [
                IconButton(
                    icon: FaIcon(FontAwesomeIcons.ellipsisV),
                    onPressed: () {
                      if (scaffoldKey.currentState != null)
                        scaffoldKey.currentState!.openEndDrawer();
                    }),
              ],
            )
          : null,
      endDrawer: widget.configuration.drawer,
      body: Center(child: rootComponent),
    );
  }
}
