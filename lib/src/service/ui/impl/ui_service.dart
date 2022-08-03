import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../../custom/custom_component.dart';
import '../../../../custom/custom_menu_item.dart';
import '../../../../custom/custom_screen.dart';
import '../../../../custom/custom_screen_manager.dart';
import '../../../../mixin/command_service_mixin.dart';
import '../../../../mixin/config_service_mixin.dart';
import '../../../../util/extensions/list_extensions.dart';
import '../../../../util/logging/flutter_logger.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/get_data_chunk_command.dart';
import '../../../model/command/data/get_meta_data_command.dart';
import '../../../model/command/data/get_selected_data_command.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_panel_model.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/data/subscriptions/data_subscription.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_group_model.dart';
import '../../../model/menu/menu_model.dart';
import '../../../model/response/dal_meta_data_response.dart';
import '../../../routing/locations/menu_location.dart';
import '../../../routing/locations/settings_location.dart';
import '../../../routing/locations/splash_location.dart';
import '../../../routing/locations/work_screen_location.dart';
import '../i_ui_service.dart';

/// Manages all interactions with the UI
class UiService with ConfigServiceGetterMixin, CommandServiceGetterMixin implements IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// ALl current menu items
  MenuModel? _menuModel;

  /// Build context of the current location, used for routing and pop-ups
  BuildContext? _currentBuildContext;

  /// List of all models currently active
  final List<FlComponentModel> _activeComponentModels = [];

  /// Live component registration
  final List<ComponentSubscription> _registeredComponents = [];

  /// All Registered data subscriptions
  final List<DataSubscription> _dataSubscriptions = [];

  /// List of all received
  final Map<String, LayoutData> _layoutDataList = {};

  /// Holds all custom screen modifications
  CustomScreenManager? customManager;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void sendCommand(BaseCommand command, [VoidCallback? onError]) {
    getCommandService().sendCommand(command).catchError((_) => onError?.call());
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Beaming history will be cleared when it should not be possible to go back,
  // as you should not be able to go back to the splash screen or back to menu when u logged out

  @override
  void routeToMenu({bool pReplaceRoute = false}) {
    var last = _currentBuildContext!.beamingHistory.last;
    if (last.runtimeType == SettingsLocation || last.runtimeType == SplashLocation) {
      _currentBuildContext!.beamingHistory.clear();
    }
    if (pReplaceRoute) {
      _currentBuildContext!.beamToReplacementNamed("/menu");
    } else {
      _currentBuildContext!.beamToNamed("/menu");
    }
  }

  @override
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false}) {
    log("routing to workscreen: $pScreenName");

    var last = _currentBuildContext!.beamingHistory.last;

    if (last.runtimeType == SettingsLocation || last.runtimeType == SplashLocation) {
      _currentBuildContext!.beamingHistory.clear();
    }
    if (pReplaceRoute) {
      _currentBuildContext!.beamToReplacementNamed("/workScreen/$pScreenName");
    } else {
      _currentBuildContext!.beamToNamed("/workScreen/$pScreenName");
    }
  }

  @override
  void routeToLogin({String mode = "manual", required Map<String, String?> pLoginProps}) {
    var last = _currentBuildContext!.beamingHistory.last;

    if (last.runtimeType == WorkScreenLocation ||
        last.runtimeType == MenuLocation ||
        last.runtimeType == SplashLocation) {
      _currentBuildContext!.beamingHistory.clear();
    }
    _currentBuildContext!.beamToNamed("/login/$mode", data: pLoginProps);
  }

  @override
  void routeToSettings({bool pReplaceRoute = false}) {
    if (pReplaceRoute) {
      _currentBuildContext!.beamToReplacementNamed("/setting");
    } else {
      _currentBuildContext!.beamToNamed("/setting");
    }
  }

  @override
  void routeToCustom({required String pFullPath}) {
    _currentBuildContext!.beamToNamed(pFullPath);
  }

  @override
  void setRouteContext({required BuildContext pContext}) {
    log("setting route context: ${pContext.widget.runtimeType}");
    _currentBuildContext = pContext;
  }

  @override
  void setCustomManager(CustomScreenManager? pCustomManager) {
    customManager = pCustomManager;
  }

  @override
  Future<T?> openDialog<T>({
    required Widget pDialogWidget,
    required bool pIsDismissible,
    Function(BuildContext context)? pContextCallback,
    Locale? pLocale,
  }) {
    return showDialog(
        context: _currentBuildContext!,
        barrierDismissible: pIsDismissible,
        builder: (BuildContext context) {
          pContextCallback?.call(context);
          Widget child = pDialogWidget;

          if (pLocale != null) {
            child = Localizations.override(context: context, child: child, locale: pLocale);
          }

          return child;
        });
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Meta data management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  MenuModel getMenuModel() {
    List<MenuGroupModel> menuGroupModels = [...?_menuModel?.menuGroups.map((e) => e.copy())];

    // Add all custom menuItems
    if (customManager != null) {
      customManager!.customScreens
          .where((element) =>
              element.showOnline && !getConfigService().isOffline() ||
              (element.showOffline && getConfigService().isOffline()))
          .forEach((element) {
        CustomMenuItem customModel = element.menuItemModel;
        // Create standard model
        MenuGroupModel? menuGroupModel =
            menuGroupModels.firstWhereOrNull((element) => element.name == customModel.group);
        if (menuGroupModel != null) {
          // Remove menu items that open the same screen
          menuGroupModel.items.removeWhere((element) => element.screenLongName == customModel.screenLongName);
          menuGroupModel.items.add(customModel);
        } else {
          // Make new group if it didn't exist
          MenuGroupModel newGroup = MenuGroupModel(
            name: customModel.group,
            items: [customModel],
          );
          menuGroupModels.add(newGroup);
        }
      });
    }

    return MenuModel(menuGroups: menuGroupModels);
  }

  @override
  void setMenuModel(MenuModel? pMenuModel) {
    _menuModel = pMenuModel;
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Management of component models
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<FlComponentModel> getChildrenModels(String id) {
    var children = _activeComponentModels.where((element) => (element.parent == id)).toList();
    return children;
  }

  @override
  FlComponentModel? getComponentModel({required String pComponentId}) {
    return _activeComponentModels.firstWhereOrNull((element) => element.id == pComponentId);
  }

  @override
  FlComponentModel? getComponentByName({required String pComponentName}) {
    return _activeComponentModels.firstWhereOrNull((element) => element.name == pComponentName);
  }

  @override
  FlPanelModel? getComponentByScreenName({required String pScreenName}) {
    return _activeComponentModels.firstWhereOrNull((element) => element.screenLongName == pScreenName) as FlPanelModel?;
  }

  @override
  void saveNewComponents({required List<FlComponentModel> newModels}) {
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Save new components: " + newModels.map((e) => e.id).toList().toString());
    _activeComponentModels.addAll(newModels);
  }

  @override
  void closeScreen({required String pScreenName, required bool pBeamBack}) {
    FlComponentModel screenModel = _activeComponentModels.firstWhere((element) => element.name == pScreenName);

    List<FlComponentModel> children = getAllComponentsBelow(screenModel.id);

    // Remove all children and itself
    _activeComponentModels.removeWhere((currentComp) =>
        currentComp == screenModel || children.any((compToDelete) => compToDelete.id == currentComp.id));

    // clear lists that get filled when new screen opens anyway
    _registeredComponents.removeWhere((currentComp) =>
        currentComp.compId == screenModel.id || children.any((compToDelete) => compToDelete.id == currentComp.compId));
    _layoutDataList
        .removeWhere((key, value) => key == screenModel.id || children.any((compToDelete) => compToDelete.id == key));
    _dataSubscriptions.removeWhere((currentComp) =>
        currentComp.id == screenModel.id || children.any((compToDelete) => compToDelete.id == currentComp.id));

    if (pBeamBack) {
      _currentBuildContext!.beamBack();
    }
  }

  @override
  List<FlComponentModel> getAllComponentsBelow(String id) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in _activeComponentModels) {
      String? parentId = componentModel.parent;
      if (parentId != null && parentId == id) {
        children.add(componentModel);
        children.addAll(getAllComponentsBelow(componentModel.id));
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
      _activeComponentModels.removeWhere((screenComponent) => screenComponent.id == inactiveId);
    }
  }

  @override
  void disposeSubscriptions({required Object pSubscriber}) {
    _dataSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
    _registeredComponents.removeWhere((element) => element.subbedObj == pSubscriber);
  }

  @override
  void disposeDataSubscription({required Object pSubscriber, String? pDataProvider}) {
    _dataSubscriptions.removeWhere((element) =>
        element.subbedObj == pSubscriber && (pDataProvider == null || element.dataProvider == pDataProvider));
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
      int index = _activeComponentModels.indexWhere((element) => element.id == updatedModel.id);
      if (index != -1) {
        _activeComponentModels[index] = updatedModel;
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
    _dataSubscriptions
        .where((sub) => sub.dataProvider == pDataProvider && sub.id == pSubId && sub.onMetaData != null)
        .forEach((element) {
      element.onMetaData!(pMetaData);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  bool hasReplaced({required String pScreenLongName}) {
    return _menuModel?.menuGroups
            .any((element) => element.items.any((element) => element.screenLongName == pScreenLongName)) ??
        false;
  }

  @override
  CustomScreen? getCustomScreen({required String pScreenName}) {
    return customManager?.customScreens
        .firstWhereOrNull((element) => element.menuItemModel.screenLongName == pScreenName);
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
