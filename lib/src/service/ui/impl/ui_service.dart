import 'dart:async';
import 'dart:collection';

import 'package:flutter_client/src/model/command/data/get_selected_data.dart';
import 'package:flutter_client/src/model/routing/route_close_qr_scanner.dart';
import 'package:flutter_client/src/model/routing/route_open_qr_scanner.dart';
import 'package:flutter_client/src/model/routing/route_to_settings_page.dart';

import '../../../../util/type_def/callback_def.dart';
import '../../../mixin/command_service_mixin.dart';
import '../../../model/command/base_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_model.dart';
import '../../../model/routing/route_to_menu.dart';
import '../../../model/routing/route_to_work_screen.dart';
import '../../../routing/app_delegate.dart';
import '../i_ui_service.dart';

/// Manages all interactions with the UI
// Author: Michael Schober
class UiService with CommandServiceMixin implements IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Used to send routing events to [AppDelegate].
  final StreamController _routeStream = StreamController.broadcast();

  /// Last open screen
  final List<FlComponentModel> _currentScreen = [];

  /// Live component registration
  final HashMap<String, ComponentCallback> _registeredComponents = HashMap();

  /// Live data components
  /// Dataprovider
  /// - Columnname
  /// -- ComponentId
  /// --- Callbacks
  final HashMap<String, Map<String, Map<String, Function>>> _registeredDataComponents = HashMap();

  /// List of all received
  final Map<String, LayoutData> _layoutDataList = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void sendCommand(BaseCommand command) {
    commandService.sendCommand(command);
  }

  @override
  void saveNewComponents({required List<FlComponentModel> newModels}) {
    _currentScreen.addAll(newModels);
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
    }
  }

  @override
  void routeToMenu(MenuModel menuModel) {
    RouteToMenu routeToMenu = RouteToMenu(menuModel: menuModel);
    _routeStream.sink.add(routeToMenu);
  }

  @override
  void routeToWorkScreen(List<FlComponentModel> screenComponents) {
    RouteToWorkScreen routeToWorkScreen = RouteToWorkScreen(screen: screenComponents.first);
    _currentScreen.clear();
    _layoutDataList.clear();
    _currentScreen.addAll(screenComponents);
    _routeStream.sink.add(routeToWorkScreen);
  }

  @override
  void routeToSettings() {
    RouteToSettingsPage settingsPage = RouteToSettingsPage();
    _routeStream.sink.add(settingsPage);
  }

  @override
  void registerAsLiveComponent({required String id, required ComponentCallback callback}) {
    _registeredComponents[id] = callback;
  }

  @override
  void registerAsDataComponent(
      {required String pDataProvider,
      required Function pCallback,
      required String pComponentId,
      required String pColumnName}) {
    if (_registeredDataComponents[pDataProvider] == null) {
      _registeredDataComponents[pDataProvider] = {
        pColumnName: {pComponentId: pCallback}
      };
    } else if (_registeredDataComponents[pDataProvider]![pColumnName] == null) {
      _registeredDataComponents[pDataProvider]![pColumnName] = {pComponentId: pCallback};
    } else {
      _registeredDataComponents[pDataProvider]![pColumnName]![pComponentId] = pCallback;
    }

    GetSelectedDataCommand command = GetSelectedDataCommand(
        reason: "reason", componentId: pComponentId, dataProvider: pDataProvider, columnName: pColumnName);
    sendCommand(command);
  }

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
      FlComponentModel model = _currentScreen.firstWhere((element) => element.id == updatedModel.id);
      model = updatedModel;

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
  List<FlComponentModel> getChildrenModels(String id) {
    var children = _currentScreen.where((element) => (element.parent == id)).toList();
    return children;
  }

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
  Stream getRouteChangeStream() {
    return _routeStream.stream;
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

  @override
  void setSelectedData(
      {required String pDataProvider, required String pComponentId, required data, required String pColumnName}) {
    _registeredDataComponents[pDataProvider]![pColumnName]![pComponentId]!.call(data);
  }

  @override
  void disposeSubscriptions({required String pComponentId}) {
    _registeredComponents.removeWhere((componentId, value) => componentId == pComponentId);
    _registeredDataComponents.forEach((key, value) {
      value.removeWhere((key, value) => key == pComponentId);
    });
  }

  @override
  void unRegisterDataComponent({required String pComponentId, required String pDataProvider}) {
    _registeredDataComponents.forEach((key, value) {
      value.removeWhere((key, value) => key == pComponentId);
    });
  }

  @override
  void closeQRScanner() {
    RouteCloseQRScanner routeCloseQRScanner = RouteCloseQRScanner();
    _routeStream.sink.add(routeCloseQRScanner);
  }

  @override
  void openQRScanner({required Function callback}) {
    RouteOpenRQScanner routeOpenRQScanner = RouteOpenRQScanner(callBack: callback);
    _routeStream.sink.add(routeOpenRQScanner);
  }
}
