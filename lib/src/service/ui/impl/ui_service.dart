import 'dart:collection';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/data/get_data_chunk_command.dart';
import 'package:flutter_client/src/model/command/data/get_meta_data_command.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/model/custom/custom_component.dart';
import 'package:flutter_client/src/model/custom/custom_menu_item.dart';
import 'package:flutter_client/src/model/custom/custom_screen.dart';
import 'package:flutter_client/src/model/custom/custom_screen_manager.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_record.dart';
import 'package:flutter_client/src/model/menu/menu_group_model.dart';
import 'package:flutter_client/src/model/menu/menu_item_model.dart';
import 'package:flutter_client/util/extensions/list_extensions.dart';

import '../../../../util/type_def/callback_def.dart';
import '../../../mixin/command_service_mixin.dart';
import '../../../model/api/response/dal_meta_data_response.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/get_selected_data_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/subscriptions/data_subscription.dart';
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

  /// Build context of the current location, used for routing and pop-ups
  BuildContext? _currentBuildContext;

  /// The name of the current work screen
  List<String> openWorkScreens = [];

  /// List of all models currently active
  final List<FlComponentModel> _currentScreen = [];

  /// Live component registration
  final HashMap<String, ComponentCallback> _registeredComponents = HashMap();

  /// All Registered data subscriptions
  final List<DataSubscription> _dataSubscriptions = [];

  /// List of all received
  final Map<String, LayoutData> _layoutDataList = {};

  /// Holds all custom screen modifications
  final CustomScreenManager? customManager;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UiService({
    this.customManager,
  });

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
    _currentBuildContext!.beamToNamed("/menu");
  }

  @override
  void routeToWorkScreen({required String pScreenName}) {
    _currentBuildContext!.beamToNamed("/workScreen/$pScreenName");
  }

  @override
  void routeToLogin({String mode = "manual"}) {
    _currentBuildContext!.beamToNamed("/login/$mode");
  }

  @override
  void routeToSettings() {
    _currentBuildContext!.beamToNamed("/setting");
  }

  @override
  void routeToCustom({required String pFullPath}) {
    _currentBuildContext!.beamToNamed(pFullPath);
  }

  @override
  void setRouteContext({required BuildContext pContext}) {
    _currentBuildContext = pContext;
  }

  @override
  Future<T?> openDialog<T>({required Widget pDialogWidget, required bool pIsDismissible}) {
    return showDialog(
        context: _currentBuildContext!,
        barrierDismissible: pIsDismissible,
        builder: (BuildContext context) {
          return pDialogWidget;
        });
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
    // Add all custom menuItems
    if (customManager != null) {
      customManager!.customScreens.forEach((element) {
        CustomMenuItem? customModel = element.menuItemModel;
        if (customModel != null) {
          // Create standard model
          MenuItemModel model = MenuItemModel(
            label: customModel.label,
            screenId: customModel.screenId,
            icon: customModel.icon,
          );
          MenuGroupModel? menuGroupModel = pMenuModel.menuGroups.firstWhereOrNull((element) => element.name == customModel.group);
          if (menuGroupModel != null) {
            // Remove menu items that open the same screen
            menuGroupModel.items.removeWhere((element) => element.screenId == customModel.screenId);
            menuGroupModel.items.add(model);
          } else {
            // Make new group if it didn't exist
            MenuGroupModel newGroup = MenuGroupModel(
              name: customModel.group,
              items: [model],
            );
            pMenuModel.menuGroups.add(newGroup);
          }
        }
      });
    }

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
    return _currentScreen.firstWhereOrNull((element) => element.id == pComponentId);
  }

  @override
  FlComponentModel? getComponentByName({required String pComponentName}) {
    return _currentScreen.firstWhereOrNull((element) => element.name == pComponentName);
  }

  @override
  void saveNewComponents({required List<FlComponentModel> newModels}) {
    _currentScreen.addAll(newModels);
  }

  @override
  void closeScreen({required String pScreenName}) {
    FlComponentModel screenModel = _currentScreen.firstWhere((element) => element.name == pScreenName);

    List<FlComponentModel> children = _getAllComponentsBelow(screenModel.id);

    // Remove all children and itself
    _currentScreen.removeWhere((currentComp) => children.any((compToDelete) => compToDelete.id == currentComp.id));
    _currentScreen.remove(screenModel);

    // clear lists that get filled when new screen opens anyway
    _registeredComponents.clear();
    _layoutDataList.clear();
    _dataSubscriptions.clear();

    _currentBuildContext!.beamBack();
  }

  @override
  FlPanelModel? getOpenScreen({required String pScreenName}) {
    return _currentScreen.firstWhereOrNull((element) => element.name == pScreenName) as FlPanelModel?;
  }

  List<FlComponentModel> _getAllComponentsBelow(String id) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in _currentScreen) {
      String? parentId = componentModel.parent;
      if (parentId != null && parentId == id) {
        children.add(componentModel);
        children.addAll(_getAllComponentsBelow(componentModel.id));
      }
    }
    return children;
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
  @Deprecated("Use Data subscription")
  void registerAsDataComponent({
    required String pDataProvider,
    required String pComponentId,
    required String pColumnName,
    required Function pColumnDefinitionCallback,
    required OnSelectedRecordCallback pCallback,
  }) {
    DataSubscription subscription = DataSubscription(
      id: pComponentId,
      dataProvider: pDataProvider,
      from: -1,
      onSelectedRecord: pCallback,
    );

    registerDataSubscription(pDataSubscription: subscription);
  }

  @override
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pShouldFetch = true}) {
    _dataSubscriptions.removeWhere((element) => element.same(pDataSubscription));
    _dataSubscriptions.add(pDataSubscription);

    if (pShouldFetch) {
      if (pDataSubscription.from != -1) {
        GetDataChunkCommand getDataChunkCommand = GetDataChunkCommand(
          reason: "Subscription added",
          dataProvider: pDataSubscription.dataProvider,
          from: pDataSubscription.from,
          to: pDataSubscription.to,
          subId: pDataSubscription.id,
          dataColumns: pDataSubscription.dataColumns,
        );
        sendCommand(getDataChunkCommand);
      }

      GetSelectedDataCommand getSelectedDataCommand = GetSelectedDataCommand(
        subId: pDataSubscription.id,
        reason: "Subscription added",
        dataProvider: pDataSubscription.dataProvider,
        columnNames: pDataSubscription.dataColumns,
      );
      sendCommand(getSelectedDataCommand);

      GetMetaDataCommand getMetaDataCommand = GetMetaDataCommand(
        reason: "Subscription added",
        dataProvider: pDataSubscription.dataProvider,
        subId: pDataSubscription.id,
      );
      sendCommand(getMetaDataCommand);
    }
  }

  @override
  void deleteInactiveComponent({required Set<String> inactiveIds}) {
    // remove subscription for removed components
    for (String inactiveId in inactiveIds) {
      _layoutDataList.remove(inactiveId);
      _currentScreen.removeWhere((screenComponent) => screenComponent.id == inactiveId);
      disposeSubscriptions(pComponentId: inactiveId);
    }
  }

  @override
  void disposeSubscriptions({required String pComponentId}) {
    _dataSubscriptions.removeWhere((element) => element.id == pComponentId);
    _registeredComponents.removeWhere((componentId, value) => componentId == pComponentId);
  }

  @override
  void disposeDataSubscription({required String pComponentId, required String pDataProvider}) {
    _dataSubscriptions.removeWhere((element) => element.id == pComponentId && element.dataProvider == pDataProvider);
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
  void notifyDataChange({
    required String pDataProvider,
    required int pFrom,
    required int pTo,
  }) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataProvider).forEach((sub) {
      // Check if selected data changed
      sendCommand(GetSelectedDataCommand(
        subId: sub.id,
        reason: "Notify data was called with pFrom -1",
        dataProvider: sub.dataProvider,
        columnNames: sub.dataColumns,
      ));
      if (sub.from != -1) {
        sendCommand(GetDataChunkCommand(
          reason: "Notify data was called",
          dataProvider: pDataProvider,
          from: sub.from,
          to: sub.to,
          subId: sub.id,
          dataColumns: sub.dataColumns,
        ));
      }
    });
  }

  @override
  void setSelectedData({
    required String pSubId,
    required String pDataProvider,
    required DataRecord? pDataRow,
  }) {
    _dataSubscriptions
        .where((element) => element.dataProvider == pDataProvider && element.id == pSubId)
        .forEach((element) => element.onSelectedRecord?.call(pDataRow));
  }

  @override
  void setChunkData({
    required String pSubId,
    required DataChunk pDataChunk,
    required String pDataProvider,
  }) {
    List<DataSubscription> subs =
        _dataSubscriptions.where((element) => element.dataProvider == pDataProvider && element.id == pSubId).toList();

    subs.forEach((element) {
      var a = element.onDataChunk;
      if (a != null) {
        a(pDataChunk);
      }
    });
  }

  @override
  void setMetaData({
    required String pSubId,
    required String pDataProvider,
    required DalMetaDataResponse pMetaData,
  }) {
    _dataSubscriptions.where((sub) => sub.dataProvider == pDataProvider && sub.id == pSubId && sub.onMetaData != null).forEach((element) {
      element.onMetaData!(pMetaData);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  CustomScreen? getCustomScreen({required String pScreenName}) {
    return customManager?.customScreens.firstWhereOrNull((element) => element.screenName == pScreenName);
  }

  @override
  CustomComponent? getCustomComponent({required String pComponentName}) {
    List<CustomScreen>? screens = customManager?.customScreens;

    if (screens != null) {
      for (CustomScreen screen in screens) {
        for (CustomComponent component in screen.replaceComponents) {
          if (component.componentName == pComponentName) {
            return component;
          }
        }
      }
    }
    return null;
  }
}
