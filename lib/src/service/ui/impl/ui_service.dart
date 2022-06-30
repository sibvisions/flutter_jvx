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
import 'package:flutter_client/util/logging/flutter_logger.dart';

import '../../../mixin/command_service_mixin.dart';
import '../../../model/api/response/dal_meta_data_response.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/get_selected_data_command.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/subscriptions/data_subscription.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_model.dart';
import '../../../routing/locations/menu_location.dart';
import '../../../routing/locations/setting_location.dart';
import '../../../routing/locations/splash_location.dart';
import '../../../routing/locations/work_screen_location.dart';
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
  final List<ComponentSubscription> _registeredComponents = [];

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
    required BuildContext pContext,
    this.customManager,
  }) {
    _currentBuildContext = pContext;
  }

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
  // Beaming history will be cleared when it should not be possible to go back,
  // as you should not be able to go back to the splash screen or back to menu when u logged out

  @override
  void routeToMenu({bool pReplaceRoute = false}) {
    var last = _currentBuildContext!.beamingHistory.last;
    if (last.runtimeType == SettingLocation || last.runtimeType == SplashLocation) {
      _currentBuildContext!.beamingHistory.clear();
    }
    _currentBuildContext!.beamToNamed("/menu");
  }

  @override
  void routeToWorkScreen({required String pScreenName}) {
    var last = _currentBuildContext!.beamingHistory.last;

    if (last.runtimeType == SettingLocation || last.runtimeType == SplashLocation) {
      _currentBuildContext!.beamingHistory.clear();
    }
    _currentBuildContext!.beamToNamed("/workScreen/$pScreenName");
  }

  @override
  void routeToLogin({String mode = "manual", required Map<String, String?> pLoginProps}) {
    var last = _currentBuildContext!.beamingHistory.last;

    if (last.runtimeType == WorkScreenLocation || last.runtimeType == MenuLocation || last.runtimeType == SplashLocation) {
      _currentBuildContext!.beamingHistory.clear();
    }
    _currentBuildContext!.beamToNamed("/login/$mode", data: pLoginProps);
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
    //log(pContext.toString());
    //log(StackTrace.current.toString());
    _currentBuildContext = pContext;
  }

  @override
  Future<T?> openDialog<T>({
    required Widget pDialogWidget,
    required bool pIsDismissible,
    Function(BuildContext context)? pContextCallback,
  }) {
    return showDialog(
        context: _currentBuildContext!,
        barrierDismissible: pIsDismissible,
        builder: (BuildContext context) {
          pContextCallback?.call(context);
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
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Save new components: " + newModels.map((e) => e.id).toList().toString());
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
    _layoutDataList[layoutData.id] = layoutData;
    _registeredComponents.where((element) => element.compId == layoutData.id).forEach((element) {
      element.callback.call(data: layoutData);
    });
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Component registration management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void registerAsLiveComponent({required ComponentSubscription pComponentSubscription}) {
    _registeredComponents.add(pComponentSubscription);
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
    }
  }

  @override
  void disposeSubscriptions({required Object pSubscriber}) {
    _dataSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
    _registeredComponents.removeWhere((element) => element.subbedObj == pSubscriber);
  }

  @override
  void disposeDataSubscription({required Object pSubscriber, required String pDataProvider}) {
    _dataSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber && element.dataProvider == pDataProvider);
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Methods to notify components about changes to themselves
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyAffectedComponents({required Set<String> affectedIds}) {
    for (String affectedId in affectedIds) {
      _registeredComponents.where((element) => element.compId == affectedId).forEach((element) {
        element.callback.call();
      });
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
      _registeredComponents.where((element) => element.compId == updatedModel.id).forEach((element) {
        element.callback(newModel: updatedModel);
      });
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
