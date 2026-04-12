/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
import 'dart:collection';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../flutter_ui.dart';
import '../../../../mask/frame/frame.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/update_components_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../util/jvx_logger.dart';
import '../../../../util/misc/jvx_notifier.dart';
import '../../../api/shared/api_object_property.dart';
import '../../../api/shared/fl_component_classname.dart';
import '../../../service.dart';
import '../../../ui/i_ui_service.dart';
import '../../i_storage_service.dart';

class StorageService implements IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all active components received from server, key set to id of [FlComponentModel].
  final HashMap<String, FlComponentModel> _componentMap = HashMap();

  /// Map of the component tree for faster traversal.
  final HashMap<String, Set<String>> _childrenTree = HashMap();

  /// The value notifier triggers rebuilds of the menu.
  late final JVxNotifier<FlComponentModel?> _desktopNotifier = JVxNotifier(
    () => _componentMap.values.firstWhereOrNull((element) => element.className == FlContainerClassname.DESKTOP_PANEL),
  );

  /// The value notifier triggers rebuilds of the menu.
  late final JVxNotifier<FlComponentModel?> _contentPanel = JVxNotifier(
    () => _componentMap.values
        .firstWhereOrNull((element) => element.classNameEventSourceRef == FlContainerClassname.DIALOG),
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StorageService.create();

  @override
  FutureOr<void> clear(ClearReason reason) {
    // The desktop panel is kept after logging out so we have to exclude it from cleaning.
    List<FlComponentModel> desktopComponentList = reason.isFull()
        ? [] // Don't keep desktop panel on full clear.
        : getAllComponentsBelowByWhere(
            where: (element) => element.className == FlContainerClassname.DESKTOP_PANEL,
            includeItself: true,
            ignoreVisibility: true,
            includeRemoved: true,
          );

    _componentMap.clear();
    _childrenTree.clear();

    desktopComponentList.forEach((element) {
      _componentMap[element.id] = element;

      _addAsChild(element);
    });
  }

  @override
  List<BaseCommand> saveComponents(
    List<dynamic>? changedComponents,
    List<FlComponentModel>? newComponents,
    bool isDesktopPanel,
    bool isContent,
    String screenName,
    bool isUpdate,
  ) {
    if ((changedComponents == null || changedComponents.isEmpty) && (newComponents == null || newComponents.isEmpty)) {
      return [];
    }

    // If we don't have the screen yet and it is an update, ignore it.
    if (isUpdate && getComponentByName(componentName: screenName) == null) {
      return [];
    }

    // List of all changed models
    Set<String> changedModels = {};
    // List of all affected models
    Set<String> affectedModels = {};

    Set<FlComponentModel> destroyedOrRemovedModels = {};

    List<FlComponentModel> oldScreenComps = _getComponents(isDesktopPanel, isContent, screenName);

    // Handle new Components
    if (newComponents != null) {
      for (FlComponentModel componentModel in newComponents) {
        // Notify parent that a new component has been added.
        String? parentId = componentModel.parent;
        if (parentId != null) {
          affectedModels.add(parentId);
        }
        _componentMap[componentModel.id] = componentModel;
        _addAsChild(componentModel);
      }
    }

    // Handle components to update
    if (changedComponents != null) {
      for (Map<String, dynamic> changedData in changedComponents) {
        String changedId = changedData[ApiObjectProperty.id];

        // Get old model
        FlComponentModel? model = _componentMap[changedId];
        if (model != null) {

          Set<String> changedProperties = changedData.keys.toSet();

          IUiService().notifyBeforeModelUpdate(changedId, changedProperties);

          // Update component and add to changedModels
          String? oldParentId = model.parent;
          bool wasVisible = model.isVisible;
          bool wasRemoved = model.isRemoved;
          model.isRemoved = false;

          model.lastChangedProperties = changedProperties;
          _removeAsChild(model);
          model.applyFromJson(changedData);
          if (model.isDestroyed) {
            _componentMap.remove(model.id);
          } else {
            _addAsChild(model);
          }
          changedModels.add(model.id);

          // Handle component removed
          if (model.isDestroyed || model.isRemoved) {
            destroyedOrRemovedModels.add(model);
          }

          // Handle parent change, notify old parent of change
          if (oldParentId != null && model.parent != oldParentId) {
            FlComponentModel? oldParent = _componentMap[oldParentId];
            if (oldParent != null) {
              affectedModels.add(oldParent.id);
            }
          }

          if ((model.isVisible != wasVisible || model.isRemoved != wasRemoved) && model.parent != null) {
            affectedModels.add(model.parent!);
          }
        }
      }
    }

    List<FlComponentModel> currentScreenComps = _getComponents(isDesktopPanel, isContent, screenName);

    List<String> newUiComponents = [];
    List<String> changedUiComponents = [];
    Set<String> deletedUiComponents = {...destroyedOrRemovedModels.map((e) => e.id)};
    Set<String> affectedUiComponents = {};

    // Build UI Notification
    // Check for new or changed active components
    // (children of now visible parents have to be added again as well)
    for (FlComponentModel currentModel in currentScreenComps) {
      // Was model already sent once, present in oldScreen
      bool existsInScreen =
          oldScreenComps.isNotEmpty && oldScreenComps.any((oldModel) => oldModel.id == currentModel.id);

      // If component has not been rendered before it is new.
      if (!existsInScreen) {
        newUiComponents.add(currentModel.id);
      } else {
        // If component has been rendered, check if it has been changed.
        bool hasChanged = changedModels.any((changedModels) => changedModels == currentModel.id);
        // If model has been changed and is still in the screen.
        if (hasChanged) {
          changedUiComponents.add(currentModel.id);
        }
      }
    }

    // Check for components which are not active anymore, e.g. not visible, removed or destroyed
    for (FlComponentModel oldModel in oldScreenComps) {
      bool existsInNewScreen = currentScreenComps.any((newModel) => newModel.id == oldModel.id);

      if (!existsInNewScreen) {
        deletedUiComponents.add(oldModel.id);
      }
    }

    // Parent components can only be affected if any other component has either changed, was deleted or is new.
    if (newUiComponents.isNotEmpty || changedUiComponents.isNotEmpty || deletedUiComponents.isNotEmpty) {
      // Only add models to affected if they are not new or changed, to avoid unnecessary re-renders.
      for (String affectedModel in affectedModels) {
        bool existsInNewScreen = currentScreenComps.any((oldModel) => oldModel.id == affectedModel);
        bool isChanged = changedUiComponents.any((changedModel) => changedModel == affectedModel);
        bool isNew = newUiComponents.any((newModel) => newModel == affectedModel);

        if (!isChanged && !isNew && existsInNewScreen) {
          affectedUiComponents.add(affectedModel);
        }
      }
    }

    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("DeletedUiComponents {${deletedUiComponents.length}}:${deletedUiComponents.toList()..sort()}");
      FlutterUI.logUI.d("Affected {${affectedUiComponents.length}}:${affectedUiComponents.toList()..sort()}");
      FlutterUI.logUI.d("Changed {${changedUiComponents.length}}:${changedUiComponents.toList()..sort()}");
      FlutterUI.logUI.d("NewUiComponents {${newUiComponents.length}}:${newUiComponents.toList()..sort()}");
    }

    // Enable to print "tree" of screen
    // getAllComponentsBelowByWhere(
    //   where: (element) => element.name == screenName,
    //   recursively: true,
    //   includeItself: true,
    //   print: true,
    // );

    UpdateComponentsCommand updateComponentsCommand = UpdateComponentsCommand(
      affectedComponents: affectedUiComponents,
      changedComponents: changedUiComponents,
      deletedComponents: deletedUiComponents,
      newComponents: newUiComponents,
      notifyDesktopPanel: isDesktopPanel,
      reason: "Server Changed Components",
    );

    return [updateComponentsCommand];
  }

  @override
  void deleteScreen({required String screenName}) {
    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("Deleting Screen: $screenName, current is: _componentMap: ${_componentMap.length}");
      FlutterUI.logUI.d(_componentMap.keys.toList().toString());
    }

    var list = _componentMap.values.where((componentModel) => componentModel.name == screenName).toList();

    for (var screenModel in list) {
      List<FlComponentModel> models = getAllComponentsBelow(
        parentModel: screenModel,
        ignoreVisibility: true,
        includeRemoved: true,
        depth: 0,
      );
      models.forEach((element) {
        _componentMap.remove(element.id);
        _childrenTree.remove(element.id);
      });
      _componentMap.remove(screenModel.id);
      _childrenTree.remove(screenModel.id);
    }

    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("Deleted Screen: $screenName, current is: _componentMap: ${_componentMap.length}");
    }
  }

  @override
  List<FlComponentModel> getAllComponentsBelow({
    required FlComponentModel parentModel,
    bool ignoreVisibility = false,
    bool includeRemoved = false,
    bool recursively = true,
    bool includeItself = false,
    bool print = false,
    int depth = 0,
  }) {
    List<FlComponentModel> allDescendants = [];
    Set<String> directChildren = _childrenTree[parentModel.id] ?? {};

    if (includeItself) {
      if (kDebugMode && print) {
        debugPrint(List.filled(depth, "-").join() + parentModel.id);
      }
      allDescendants.add(parentModel);
    }

    for (String childId in directChildren) {
      FlComponentModel? childModel = _componentMap[childId];
      if (childModel != null && !includeRemoved && childModel.isRemoved) {
        childModel = null;
      }
      // Tab-set panel set non selected sub-panels as invisible.
      // We always render them though, even the invisible panels,
      // therefore tab-set children are always visible for us.
      if (childModel != null &&
          (ignoreVisibility || childModel.isVisible || parentModel.className == FlContainerClassname.TABSET_PANEL)) {
        allDescendants.add(childModel);
        if (kDebugMode && print) {
          debugPrint(List.filled(depth + 1, "-").join() + childModel.id);
        }
        if (recursively) {
          allDescendants.addAll(
            getAllComponentsBelow(
              parentModel: childModel,
              ignoreVisibility: ignoreVisibility,
              includeRemoved: includeRemoved,
              recursively: recursively,
              print: print,
              depth: depth + 1,
            ),
          );
        }
      }
    }

    return allDescendants;
  }

  @override
  List<FlComponentModel> getAllComponentsBelowByName({
    required String name,
    bool ignoreVisibility = false,
    bool includeRemoved = false,
    bool recursively = true,
    bool includeItself = false,
  }) {
    return getAllComponentsBelowByWhere(
      where: (element) => element.name == name,
      ignoreVisibility: ignoreVisibility,
      includeRemoved: includeRemoved,
      recursively: recursively,
      includeItself: includeItself,
    );
  }

  @override
  List<FlComponentModel> getAllComponentsBelowById({
    required String parentId,
    bool ignoreVisibility = false,
    bool includeRemoved = false,
    bool recursively = true,
    bool includeItself = false,
  }) {
    return getAllComponentsBelowByWhere(
      where: (element) => element.id == parentId,
      ignoreVisibility: ignoreVisibility,
      includeRemoved: includeRemoved,
      recursively: recursively,
      includeItself: includeItself,
    );
  }

  List<FlComponentModel> getAllComponentsBelowByWhere({
    required bool Function(FlComponentModel) where,
    bool ignoreVisibility = false,
    bool includeRemoved = false,
    bool recursively = true,
    bool includeItself = false,
    bool print = false,
    int depth = 0,
  }) {
    List<FlComponentModel> list = [];
    List<FlComponentModel> screenModels = _componentMap.values.where(where).toList();

    if (screenModels.length >= 2) {
      FlutterUI.logUI.f("The same screen is found twice in the storage service!!!!");
    } else if (screenModels.length == 1 &&
        (ignoreVisibility || screenModels.first.isVisible) &&
        (includeRemoved || !screenModels.first.isRemoved)) {
      list.addAll(
        getAllComponentsBelow(
          parentModel: screenModels.first,
          ignoreVisibility: ignoreVisibility,
          includeRemoved: includeRemoved,
          recursively: recursively,
          includeItself: includeItself,
          print: print,
          depth: depth,
        ),
      );
    }

    return list;
  }

  @override
  FlComponentModel? getComponentModel({required String componentId}) {
    return _componentMap[componentId];
  }

  @override
  FlComponentModel? getComponentByName({required String componentName}) {
    return _componentMap.values.firstWhereOrNull((element) => element.name == componentName);
  }

  @override
  FlPanelModel? getComponentByScreenClassName({required String screenClassName}) {
    String className = convertLongScreenToClassName(screenClassName);

    return _componentMap.values
        .whereType<FlPanelModel>()
        .firstWhereOrNull((element) => element.screenClassName == className);
  }

  @override
  FlPanelModel? getComponentByNavigationName(String navigationName) {
    return _componentMap.values
        .whereType<FlPanelModel>()
        .firstWhereOrNull((element) => element.screenNavigationName == navigationName);
  }

  @override
  List<FlPanelModel> getScreens() {
    return _componentMap.values
        .whereType<FlPanelModel>()
        .where((element) => element.screenNavigationName?.isNotEmpty ?? false)
        .toList();
  }

  @override
  JVxNotifier<FlComponentModel?> getDesktopPanelNotifier() {
    return _desktopNotifier;
  }

  @override
  JVxNotifier<FlComponentModel?> getContentPanelNotifier() {
    return _contentPanel;
  }

  @override
  bool isVisibleInUI(String componentId) {
    FlComponentModel? compModel = _componentMap[componentId];

    if (compModel == null) {
      return false;
    }

    List<FlComponentModel> components = [compModel];
    while (compModel!.parent != null && _componentMap[compModel.parent] != null) {
      compModel = _componentMap[compModel.parent];
      components.add(compModel!);
    }

    if (components.any((element) => !element.isVisible || element.isRemoved || element.isDestroyed)) {
      return false;
    }

    if (components.last.className == FlContainerClassname.DESKTOP_PANEL) {
      return Frame.isWebFrame() &&
          (FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState).pathPatternSegments.contains("menu");
    } else if (components.last.classNameEventSourceRef == FlContainerClassname.DIALOG) {
      return IUiService().isContentVisible(components.last.name);
    } else {
      return (components.last as FlPanelModel).screenNavigationName == IUiService().getCurrentWorkScreenName();
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _addAsChild(FlComponentModel child) {
    if (child.parent != null && child.parent!.isNotEmpty) {
      Set<String> children = _childrenTree[child.parent] ?? {};
      children.add(child.id);
      _childrenTree[child.parent!] = children;
    }
  }

  void _removeAsChild(FlComponentModel child) {
    if (child.parent != null && child.parent!.isNotEmpty) {
      Set<String> children = _childrenTree[child.parent] ?? {};
      children.remove(child.id);
      _childrenTree[child.parent!] = children;
    }
  }

  @override
  String convertLongScreenToClassName(String screenLongName) {
    return screenLongName.split(":")[0];
  }

  @override
  List<FlComponentModel> getComponentModels() {
    return List.of(_componentMap.values);
  }

  List<FlComponentModel> _getComponents(bool isDesktopPanel, bool isContent, String screenName) {
    if (isDesktopPanel) {
      return getAllComponentsBelowByWhere(
        where: (element) => element.className == FlContainerClassname.DESKTOP_PANEL,
        includeItself: true,
      );
    } else if (isContent) {
      return getAllComponentsBelowByWhere(
        where: (element) => element.classNameEventSourceRef == FlContainerClassname.DIALOG,
        includeItself: true,
      );
    } else {
      return getAllComponentsBelowByName(
        name: screenName,
        includeItself: true,
      );
    }
  }
}
