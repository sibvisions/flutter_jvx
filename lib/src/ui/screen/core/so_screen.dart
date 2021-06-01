import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutterclient.dart';
import '../../../models/api/requests/press_button_request.dart';
import '../../../models/api/response_objects/close_screen_action_response_object.dart';
import '../../../models/api/response_objects/menu/menu_item.dart';
import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component.dart';
import '../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../models/state/app_state.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/color/color_extension.dart';
import '../../component/component_widget.dart';
import '../../component/model/component_model.dart';
import '../../component/popup_menu/co_menu_item_widget.dart';
import '../../component/popup_menu/co_popup_menu_button_widget.dart';
import '../../component/popup_menu/co_popup_menu_widget.dart';
import '../../component/popup_menu/models/popup_menu_component_model.dart';
import '../../container/co_container_widget.dart';
import '../../container/co_panel_widget.dart';
import '../../container/models/container_component_model.dart';
import '../../editor/cell_editor/co_referenced_cell_editor_widget.dart';
import '../../editor/co_editor_widget.dart';
import '../../editor/editor_component_model.dart';
import '../../util/inherited_widgets/app_state_provider.dart';
import '../../widgets/page/menu/browser/navigation_bar_widget.dart';
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

  bool _debug = false;

  Map<String, ComponentWidget> get components => _components;

  void onState(ApiState? state) {
    if (state is ApiResponse && widget.configuration.withServer) {
      _checkForCloseScreenAction(state);

      update(state);

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

  // void relayoutParentLayouts(String componentId) {
  //   bool _formLayoutFound = false;

  //   if (_components.containsKey(componentId)) {
  //     ComponentWidget componentWidget = _components[componentId]!;
  //     if (componentWidget.componentModel is ContainerComponentModel) {
  //       ContainerComponentModel model =
  //           (componentWidget.componentModel as ContainerComponentModel);
  //       // if (model.layout != null &&
  //       //     model.layout?.setState != null &&
  //       //     (model.layout is CoFormLayoutContainerWidget ||
  //       //         model.layout is CoBorderLayoutContainerWidget)) {
  //       //   log('Relayout $componentId');
  //       //   model.layout!.setState!(() {});
  //       //   _formLayoutFound = true;
  //       // }
  //     }
  //     if (componentWidget.componentModel.parentComponentId.isNotEmpty) {
  //       //&&
  //       //  !_formLayoutFound) {
  //       relayoutParentLayouts(componentWidget.componentModel.parentComponentId);
  //     }
  //   }
  // }

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

        bool relayoutParent = false;
        bool? visible =
            changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, null);

        if (visible != null &&
            visible != componentWidget.componentModel.isVisible) {
          relayoutParent = true;
        }

        componentWidget.componentModel
            .updateProperties(context, changedComponent);

        if (container
            .containsKey(componentWidget.componentModel.parentComponentId)) {
          ComponentWidget parentComponentWidget =
              container[componentWidget.componentModel.parentComponentId]!;

          if (parentComponentWidget is CoContainerWidget) {
            (parentComponentWidget.componentModel as ContainerComponentModel)
                .updateComponentProperties(
                    context,
                    componentWidget.componentModel.componentId,
                    changedComponent);
          }
        }

        if (relayoutParent) {
          // relayoutParentLayouts(componentWidget.componentModel.componentId);
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
    ComponentWidget? componentWidget;

    if (!container.containsKey(changedComponent.id) &&
        changedComponent.className != null &&
        changedComponent.className!.isNotEmpty) {
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

        if (componentWidget.cellEditor is CoReferencedCellEditorWidget &&
            (componentWidget.cellEditor as CoReferencedCellEditorWidget)
                    .cellEditorModel
                    .cellEditor
                    .linkReference
                    ?.dataProvider !=
                null) {
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
    } else if (container.containsKey(changedComponent.id)) {
      componentWidget = container[changedComponent.id]!;

      if (componentWidget is CoEditorWidget) {
        (componentWidget.componentModel as EditorComponentModel).data =
            getComponentData(
                (componentWidget.componentModel as EditorComponentModel)
                    .dataProvider!);

        if (componentWidget.cellEditor is CoReferencedCellEditorWidget &&
            (componentWidget.cellEditor as CoReferencedCellEditorWidget)
                    .cellEditorModel
                    .cellEditor
                    .linkReference
                    ?.dataProvider !=
                null) {
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

    if (componentWidget != null) {
      componentWidget.componentModel.state = CoState.Added;
      container.putIfAbsent(changedComponent.id!, () => componentWidget!);
      _addToParent(componentWidget, container);
    }
  }

  void _addToParent(
      ComponentWidget componentWidget, Map<String, ComponentWidget> container) {
    if (componentWidget.componentModel.parentComponentId.isNotEmpty) {
      ComponentWidget? parentComponentWidget =
          container[componentWidget.componentModel.parentComponentId];

      if (parentComponentWidget != null &&
          parentComponentWidget is CoContainerWidget) {
        (parentComponentWidget.componentModel as ContainerComponentModel)
            .addWithConstraints(
                componentWidget, componentWidget.componentModel.constraints);

        // relayoutParentLayouts(parentComponentWidget.componentModel.componentId);
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
    if (componentWidget.componentModel.parentComponentId.isNotEmpty) {
      ComponentWidget? parentComponentWidget =
          container[componentWidget.componentModel.parentComponentId];

      if (parentComponentWidget != null &&
          parentComponentWidget is CoContainerWidget) {
        (parentComponentWidget.componentModel as ContainerComponentModel)
            .removeWithComponent(componentWidget);

        // relayoutParentLayouts(parentComponentWidget.componentModel.componentId);
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
        if (_debug) {
          print(
              'Update layoutData (id: ${changedComponent.id}, newLayoutData: $layoutData, className: ${changedComponent.className})');
        }

        (componentWidget.componentModel as ContainerComponentModel)
            .layout
            ?.layoutModel
            .updateLayoutData(layoutData);
      }

      if (layout != null && layout.isNotEmpty) {
        if (_debug) {
          print(
              'Update layoutString (id: ${changedComponent.id}, newLayoutString: $layout, className: ${changedComponent.className})');
        }

        (componentWidget.componentModel as ContainerComponentModel)
            .layout
            ?.layoutModel
            .updateLayoutString(layout);
      }
    }

    if (parent != null &&
        parent.isNotEmpty &&
        componentWidget.componentModel.parentComponentId != parent) {
      if (_debug) {
        print(
            'Move component (id: ${changedComponent.id}, oldParent: ${componentWidget.componentModel.parentComponentId}, newParent: $parent, className: ${changedComponent.className}');
      }

      if (componentWidget.componentModel.parentComponentId.isNotEmpty) {
        _removeFromParent(componentWidget, container);
      }

      componentWidget.componentModel.parentComponentId = parent;
      _addToParent(componentWidget, container);
    }

    if (constraints != null &&
        constraints.isNotEmpty &&
        constraints != componentWidget.componentModel.constraints) {
      componentWidget.componentModel.constraints = constraints;

      if (container
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
            componentWidget.componentModel.parentComponentId.isEmpty &&
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
        _components[header!.componentModel.componentId] = header!;
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
        _components[footer!.componentModel.componentId] = footer!;
      }

      _components[HEADER_FOOTER_PANEL_COMPONENT_ID] = headerFooterPanel;

      if (rootComponent != null) {
        (headerFooterPanel.componentModel as ContainerComponentModel)
            .addWithConstraints(header!, header!.componentModel.constraints);
        (headerFooterPanel.componentModel as ContainerComponentModel)
            .addWithConstraints(
                rootComponent, rootComponent.componentModel.constraints);
        (headerFooterPanel.componentModel as ContainerComponentModel)
            .addWithConstraints(footer!, footer!.componentModel.constraints);
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

  void debugPrintCurrentWidgetTree() {
    ComponentWidget? component = getRootComponent();
    if (_debug && component != null) {
      print("--------------------");
      print("Current widget tree:");
      print("--------------------");
      debugPrintComponent(component, 0);
      print("--------------------");
    }
  }

  void debugPrintComponent(ComponentWidget component, int level) {
    String debugString = " |" * level;
    debugString += " id: " +
        component.componentModel.componentId.toString() +
        ", Name: " +
        component.componentModel.name.toString() +
        ", parent: " +
        component.componentModel.parentComponentId +
        ", className: " +
        component.runtimeType.toString() +
        ", constraints: " +
        component.componentModel.constraints +
        ", text:" +
        component.componentModel.text;
    if (component is CoEditorWidget) {
      debugString += ", dataProvider: " +
          ((component.cellEditor?.cellEditorModel.dataProvider != null)
              ? component.cellEditor!.cellEditorModel.dataProvider!
              : "");
    }
    if (component is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          component.componentModel as ContainerComponentModel;

      debugString += ", layout: " +
          (containerComponentModel.layout != null &&
                  containerComponentModel.layout?.layoutModel.rawLayoutString !=
                      null
              ? containerComponentModel.layout!.layoutModel.rawLayoutString
              : "") +
          ", layoutData: " +
          (containerComponentModel.layout != null &&
                  containerComponentModel.layout?.layoutModel.rawLayoutData !=
                      null
              ? containerComponentModel.layout!.layoutModel.rawLayoutData
              : "") +
          ", childCount: " +
          containerComponentModel.components.length.toString();
      print(debugString);
      if (containerComponentModel.components.isNotEmpty) {
        containerComponentModel.components.forEach((c) {
          debugPrintComponent(c, (level + 1));
        });
      }
    } else {
      print(debugString);
    }
  }

  AppBar getDefaultAppBar() {
    return AppBar(
      actionsIconTheme:
          IconThemeData(color: Theme.of(context).primaryColor.textColor()),
      title: Text(
        '${widget.configuration.screenTitle}',
        style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
      ),
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor.textColor(),
          ),
          onPressed: () {
            widget.configuration.onPopPage!(widget.configuration.componentId);
          }),
      actions: [
        if (componentData.isNotEmpty)
          IconButton(
              icon: FaIcon(
                FontAwesomeIcons.redo,
                size: 19,
              ),
              onPressed: () async {
                for (final cd in componentData) {
                  cd.getData(context, -1);
                }
              }),
        IconButton(
            icon: FaIcon(FontAwesomeIcons.ellipsisV),
            onPressed: () {
              if (scaffoldKey.currentState != null)
                scaffoldKey.currentState!.openEndDrawer();
            }),
      ],
    );
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

    widget.configuration.value = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrintCurrentWidgetTree();

    return OrientationBuilder(
      builder: (context, orientation) {
        AppState appState = AppStateProvider.of(context)!.appState;
        List<MenuItem> menuItems = appState.menuResponseObject.entries;

        menuItems =
            appState.screenManager.onMenu(SoMenuManager(menuItems)).menuItems;

        return Scaffold(
            key: scaffoldKey,
            appBar: shouldShowAppBar(appState, orientation)
                ? getDefaultAppBar()
                : null,
            endDrawer: widget.configuration.drawer,
            body: SafeArea(
              child: shouldShowNavigationBar(appState, orientation)
                  ? NavigationBarWidget(
                      appState: appState,
                      menuItems: menuItems,
                      onLogoutPressed: () {},
                      onMenuItemPressed: (MenuItem menuItem) {
                        if (widget.configuration.onMenuItemPressed != null) {
                          widget.configuration.onMenuItemPressed!(menuItem);
                        }
                      },
                      child: rootComponent as Widget)
                  : rootComponent!,
            ));
      },
    );
  }

  bool shouldShowNavigationBar(AppState appState, Orientation orientation) {
    if (appState.mobileOnly) return false;

    if (appState.webOnly) return true;

    if (kIsWeb && orientation == Orientation.landscape)
      return true;
    else
      return false;
  }

  bool shouldShowAppBar(AppState appState, Orientation orientation) {
    if (appState.mobileOnly) return true;

    if (appState.webOnly) return false;

    if (!kIsWeb) return true;

    if (kIsWeb && orientation == Orientation.portrait) return true;

    return false;
  }
}
