import 'dart:collection';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/routing/locations/work_sceen_location.dart';

import '../../../../util/type_def/callback_def.dart';
import '../../../mixin/command_service_mixin.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/get_selected_data.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_model.dart';
import '../i_ui_service.dart';

/// Manages all interactions with the UI
class UiService with CommandServiceMixin implements IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// ALl current menu items
  MenuModel? _menuModel;

  BuildContext? _currentBuildContext;

  /// List of all models currently active
  final List<FlComponentModel> _currentScreen = [];

  /// Live component registration
  final HashMap<String, ComponentCallback> _registeredComponents = HashMap();

  /// Live data components
  /// Dataprovider
  /// - Columnname
  /// -- ComponentId
  /// --- Callbacks
  final HashMap<String, Map<String, Map<String, Function>>> _registeredDataComponents = HashMap();

  /// List of all one-time-use columnDefinition callBacks
  final HashMap<String, Map<String, Map<String, Function>>> _columnDefinitionCallback = HashMap();

  /// List of all received
  final Map<String, LayoutData> _layoutDataList = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void sendCommand(BaseCommand command) {
    commandService.sendCommand(command);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void routeToMenu({bool pReplaceRoute = false}) {
    if (pReplaceRoute) {
      _currentBuildContext!.beamToReplacementNamed("/menu");
    } else {
      _currentBuildContext!.beamToNamed("/menu");
    }
  }

  @override
  void routeToWorkScreen() {
    var screen = _currentScreen.first;
    if(_currentBuildContext!.beamingHistory.last is WorkScreenLocation){
      _currentBuildContext!.beamToReplacementNamed("/workScreen/${screen.id}");
    } else {
      _currentBuildContext!.beamToNamed("/workScreen/${screen.id}");
    }
  }

  @override
  void routeToLogin() {
    if(_currentBuildContext!.beamingHistory.last is WorkScreenLocation){
      _currentBuildContext!.beamToReplacementNamed("/login");
    } else {
      _currentBuildContext!.beamToNamed("/login");
    }
  }

  @override
  void routeToSettings() {
    _currentBuildContext!.beamToNamed("/settings");
  }

  @override
  void setRouteContext({required BuildContext pContext}) {
    _currentBuildContext = pContext;
  }

  @override
  Future<bool?> openDialog<T>({required Widget pDialogWidget, required bool pIsDismissible}){
    return showDialog(
        context: _currentBuildContext!,
        barrierDismissible: pIsDismissible,
        builder: (BuildContext context) {
          return pDialogWidget;
        }
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Meta data management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  MenuModel getMenuModel() {
    if (_menuModel != null) {
      return _menuModel!;
    } else {
      throw Exception("Menu model was not set, needs to be set before opening menu");
    }
  }

  @override
  void setMenuModel({required MenuModel pMenuModel}) {
    _menuModel = pMenuModel;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Management of component models
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<FlComponentModel> getChildrenModels(String id) {
    var children = _currentScreen.where((element) => (element.parent == id)).toList();
    return children;
  }

  @override
  FlComponentModel? getComponentModel({required String pComponentId}) {
    int index = _currentScreen.indexWhere((element) => element.id == pComponentId);
    if (index != -1) {
      return _currentScreen[index];
    }
  }

  @override
  void saveNewComponents({required List<FlComponentModel> newModels}) {
    _currentScreen.addAll(newModels);
  }

  @override
  FlComponentModel getScreenByName({required String pScreenName}) {
    throw UnimplementedError();
  }

  @override
  void closeScreen({required String pScreenName}) {
    //ToDo only delete components belonging to screen
    // for (var element in _currentScreen) {
    //   if(element is FlPanelModel){
    //
    //   }
    // }
    _currentScreen.clear();
    _registeredComponents.clear();
    _registeredDataComponents.clear();
    _columnDefinitionCallback.clear();
    _layoutDataList.clear();
  }

  @override
  FlPanelModel getOpenScreen() {
    return _currentScreen.first as FlPanelModel;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // LayoutData management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<LayoutData> getChildrenLayoutData({required String pParentId}) {
    List<LayoutData> childrenData = [];
    _layoutDataList.forEach((key, value) {
      if (value.parentId == pParentId) {
        childrenData.add(value);
      }
    });
    return childrenData;
  }

  @override
  void setLayoutPosition({required LayoutData layoutData}) {
    ComponentCallback? callback = _registeredComponents[layoutData.id];
    _layoutDataList[layoutData.id] = layoutData;
    if (callback != null) {
      callback.call(data: layoutData);
    } else {
      // throw Exception("Component to set position not found");
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void registerAsLiveComponent({required String id, required ComponentCallback callback}) {
    _registeredComponents[id] = callback;
  }

  @override
  void registerAsDataComponent({
    required String pDataProvider,
    required String pComponentId,
    required String pColumnName,
    required Function pColumnDefinitionCallback,
    required Function pCallback,
  }) {
    if (_registeredDataComponents[pDataProvider] == null) {
      _registeredDataComponents[pDataProvider] = {
        pColumnName: {pComponentId: pCallback}
      };
      _columnDefinitionCallback[pDataProvider] = {
        pColumnName: {pComponentId: pColumnDefinitionCallback}
      };
    } else if (_registeredDataComponents[pDataProvider]![pColumnName] == null) {
      _registeredDataComponents[pDataProvider]![pColumnName] = {pComponentId: pCallback};
      _columnDefinitionCallback[pDataProvider]![pColumnName] = {pComponentId: pColumnDefinitionCallback};
    } else {
      _registeredDataComponents[pDataProvider]![pColumnName]![pComponentId] = pCallback;
      _columnDefinitionCallback[pDataProvider]![pColumnName]![pComponentId] = pColumnDefinitionCallback;
    }

    GetSelectedDataCommand command = GetSelectedDataCommand(
        reason: "reason", componentId: pComponentId, dataProvider: pDataProvider, columnName: pColumnName);
    sendCommand(command);
  }

  @override
  void deleteInactiveComponent({required Set<String> inactiveIds}) {
    // remove subscription for components removed from ui
    for (String inactiveId in inactiveIds) {
      _layoutDataList.remove(inactiveId);
      _currentScreen.removeWhere((screenComponent) => screenComponent.id == inactiveId);
      _registeredComponents.removeWhere((componentId, value) => componentId == inactiveId);
      _registeredDataComponents.forEach((key, value) {
        value.removeWhere((key, value) => key == inactiveId);
      });
      _columnDefinitionCallback.forEach((key, value) {
        value.removeWhere((key, value) => key == inactiveId);
      });
    }
  }

  @override
  void disposeSubscriptions({required String pComponentId}) {
    _registeredComponents.removeWhere((componentId, value) => componentId == pComponentId);
    _registeredDataComponents.forEach((key, value) {
      value.removeWhere((key, value) => key == pComponentId);
    });
    _columnDefinitionCallback.forEach((key, value) {
      value.removeWhere((key, value) => key == pComponentId);
    });
  }

  @override
  void unRegisterDataComponent({required String pComponentId, required String pDataProvider}) {
    _registeredDataComponents.forEach((key, value) {
      value.removeWhere((key, value) => key == pComponentId);
    });
    _columnDefinitionCallback.forEach((key, value) {
      value.removeWhere((key, value) => key == pComponentId);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyAffectedComponents({required Set<String> affectedIds}) {
    for (String affectedId in affectedIds) {
      ComponentCallback? callback = _registeredComponents[affectedId];
      if (callback != null) {
        callback.call();
      }
    }
  }

  @override
  void notifyChangedComponents({required List<FlComponentModel> updatedModels}) {
    for (FlComponentModel updatedModel in updatedModels) {
      // Change to new Model
      int index = _currentScreen.indexWhere((element) => element.id == updatedModel.id);
      if (index != -1) {
        _currentScreen[index] = updatedModel;
      }

      // Notify active component
      ComponentCallback? callback = _registeredComponents[updatedModel.id];
      if (callback != null) {
        callback.call(newModel: updatedModel);
      } else {
        throw Exception("Component ${updatedModel.id} To Update not found");
      }
    }
  }

  @override
  void notifyDataChange({required String pDataProvider}) {
    var dataProviderCallbacks = _registeredDataComponents[pDataProvider];

    if (dataProviderCallbacks != null) {
      for (String columnName in dataProviderCallbacks.keys) {
        for (String componentId in dataProviderCallbacks[columnName]!.keys) {
          GetSelectedDataCommand command = GetSelectedDataCommand(
              reason: "reason", componentId: componentId, dataProvider: pDataProvider, columnName: columnName);
          sendCommand(command);
        }
      }
    }
  }

  @override
  void setSelectedData({
    required String pDataProvider,
    required String pComponentId,
    required pData,
    required String pColumnName,
  }) {
    _registeredDataComponents[pDataProvider]![pColumnName]![pComponentId]!.call(pData);
  }

  @override
  void setSelectedColumnDefinition(
      {required String pDataProvider,
      required String pComponentId,
      required String pColumnName,
      required ColumnDefinition pColumnDefinition}) {
    _columnDefinitionCallback[pDataProvider]![pColumnName]![pComponentId]!.call(pColumnDefinition);
  }
}
