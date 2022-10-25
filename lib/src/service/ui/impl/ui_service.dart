import 'dart:async';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../commands.dart';
import '../../../../custom/app_manager.dart';
import '../../../../custom/custom_component.dart';
import '../../../../custom/custom_menu_item.dart';
import '../../../../custom/custom_screen.dart';
import '../../../../flutter_jvx.dart';
import '../../../../services.dart';
import '../../../exceptions/error_view_exception.dart';
import '../../../mask/error/message_dialog.dart';
import '../../../mask/frame_dialog.dart';
import '../../../mask/jvx_overlay.dart';
import '../../../model/command/api/save_all_editors.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_panel_model.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/data/subscriptions/data_subscription.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_group_model.dart';
import '../../../model/response/dal_meta_data_response.dart';
import '../../../routing/locations/login_location.dart';
import '../../../routing/locations/settings_location.dart';
import '../../../routing/locations/work_screen_location.dart';

/// Manages all interactions with the UI
class UiService implements IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// All current menu items
  MenuModel? _menuModel;

  /// List of all known models
  final List<FlComponentModel> _componentModels = [];

  /// All component subscriptions
  final List<ComponentSubscription> _componentSubscriptions = [];

  /// All data subscriptions
  final List<DataSubscription> _dataSubscriptions = [];

  /// Map of all active frames (dialogs) with their componentId
  final Map<String, MessageDialog> _activeFrames = {};
  final List<FrameDialog> _activeDialogs = [];

  /// Holds all custom screen modifications
  AppManager? appManager;

  /// TODO: Holds previously calculated TableSizes

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void clear() {
    _menuModel = null;
    _componentModels.clear();
    _componentSubscriptions.clear();
    _dataSubscriptions.clear();
    _activeFrames.clear();
    _activeDialogs.clear();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<void> sendCommand(BaseCommand command, {Function(Object error, StackTrace stackTrace)? onError}) {
    return ICommandService().sendCommand(command).catchError((error, stackTrace) {
      if (onError != null) {
        onError.call(error, stackTrace);
      } else {
        handleAsyncError(error, stackTrace);
      }
    });
  }

  @override
  void handleAsyncError(Object error, StackTrace stackTrace) {
    FlutterJVx.log.e("Error while sending async command", error, stackTrace);

    if (error is! ErrorViewException) {
      bool isTimeout = error is TimeoutException || error is SocketException;
      ICommandService().sendCommand(OpenErrorDialogCommand(
        message: IUiService.getErrorMessage(error),
        error: error,
        canBeFixedInSettings: isTimeout,
        reason: "Command error in ui service",
      ));
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Beaming history will be cleared when it should not be possible to go back,
  // as you should not be able to go back to the splash screen or back to menu when u logged out

  @override
  void routeToMenu({bool pReplaceRoute = false}) {
    if (FlutterJVx.getCurrentContext() == null) {
      // TODO fix workScreen web reload (e.g. send OpenScreenCommand)
      // Potential Idea -> Go to menu on workscreen but send an OpenScreenCommand,
      // which will route to the work screen once it is finished and returned.
      //if (!kIsWeb || Uri.base.fragment != "/settings" /* && !Uri.base.fragment.startsWith("/workScreen")*/) {
      routerDelegate.setNewRoutePath(const RouteInformation(location: "/menu"));
      //}
      return;
    }

    var last = FlutterJVx.getCurrentContext()!.currentBeamLocation;
    if (pReplaceRoute || last.runtimeType == SettingsLocation || last.runtimeType == LoginLocation) {
      FlutterJVx.getCurrentContext()!.beamToReplacementNamed("/menu");
    } else {
      FlutterJVx.getCurrentContext()!.beamToNamed("/menu");
    }
  }

  @override
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false}) {
    FlutterJVx.log.i("Routing to workscreen: $pScreenName");

    if (FlutterJVx.getCurrentContext() == null) {
      // TODO: See [routeToMenu]
      //if (!kIsWeb || Uri.base.fragment != "/settings" /* && !Uri.base.fragment.startsWith("/workScreen")*/) {
      routerDelegate.setNewRoutePath(RouteInformation(location: "/workScreen/$pScreenName"));
      //}
      return;
    }

    BeamLocation lastLocation = FlutterJVx.getCurrentContext()!.currentBeamLocation;

    bool justReload = false;

    if (lastLocation.runtimeType == WorkScreenLocation) {
      BeamState beamState = lastLocation.state as BeamState;
      if (beamState.pathParameters['workScreenName'] == pScreenName) {
        justReload = true;
      }
    }

    Map<String, dynamic> beamData = {};
    beamData['reload'] = justReload;

    if (pReplaceRoute || lastLocation.runtimeType == SettingsLocation || lastLocation.runtimeType == LoginLocation) {
      FlutterJVx.getCurrentContext()!.beamToReplacementNamed("/workScreen/$pScreenName", data: beamData);
    } else {
      FlutterJVx.getCurrentContext()!.beamToNamed("/workScreen/$pScreenName", data: beamData);
    }
  }

  @override
  void routeToLogin({String mode = "manual", required Map<String, String?> pLoginProps}) {
    if (FlutterJVx.getCurrentContext() == null) {
      // TODO: See [routeToMenu]
      // if (!kIsWeb || Uri.base.fragment != "/settings" /* && !Uri.base.fragment.startsWith("/workScreen")*/) {
      routerDelegate.setNewRoutePath(RouteInformation(location: "/login/$mode"));
      // }
      return;
    }

    FlutterJVx.getCurrentContext()!.beamToReplacementNamed("/login/$mode", data: pLoginProps);
  }

  @override
  void routeToSettings({bool pReplaceRoute = false}) {
    if (FlutterJVx.getCurrentContext() == null) {
      routerDelegate.setNewRoutePath(const RouteInformation(location: "/settings"));
      return;
    }

    if (pReplaceRoute) {
      FlutterJVx.getCurrentContext()!.beamToReplacementNamed("/settings");
    } else {
      FlutterJVx.getCurrentContext()!.beamToNamed("/settings");
    }
  }

  @override
  void routeToCustom({required String pFullPath}) {
    FlutterJVx.getCurrentContext()!.beamToNamed(pFullPath);
  }

  @override
  AppManager? getAppManager() {
    return appManager;
  }

  @override
  void setAppManager(AppManager? pAppManager) {
    appManager = pAppManager;
  }

  @override
  Future<T?> openDialog<T>({
    required WidgetBuilder pBuilder,
    BuildContext? context,
    bool pIsDismissible = true,
    Locale? pLocale,
  }) =>
      showDialog(
          context: context ?? FlutterJVx.getCurrentContext()!,
          barrierDismissible: pIsDismissible,
          builder: (BuildContext context) {
            Widget child = pBuilder.call(context);

            if (pLocale != null) {
              child = Localizations.override(context: context, locale: pLocale, child: child);
            }

            return WillPopScope(
              child: child,
              onWillPop: () async => pIsDismissible,
            );
          });

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Meta data management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  MenuModel getMenuModel() {
    List<MenuGroupModel> menuGroupModels = [...?_menuModel?.menuGroups.map((e) => e.copy())];

    // Add all custom menuItems
    if (appManager != null) {
      appManager!.customScreens.where((customScreen) => customScreen.menuItemModel != null).forEach((customScreen) {
        CustomMenuItem customMenuItem = customScreen.menuItemModel!;

        // Remove menu items that open the same screen
        menuGroupModels.forEach((menuGroup) =>
            menuGroup.items.removeWhere((menuItem) => menuItem.screenLongName == customMenuItem.screenLongName));

        if ((customScreen.showOnline && !IConfigService().isOffline()) ||
            (customScreen.showOffline && IConfigService().isOffline())) {
          // Check if group already exists
          MenuGroupModel? menuGroupModel =
              menuGroupModels.firstWhereOrNull((element) => element.name == customMenuItem.group);
          if (menuGroupModel != null) {
            menuGroupModel.items.add(customMenuItem);
          } else {
            // Make new group if it didn't exist
            MenuGroupModel newGroup = MenuGroupModel(
              name: customMenuItem.group,
              items: [customMenuItem],
            );
            menuGroupModels.add(newGroup);
          }
        }
      });
    }

    MenuModel menuModel = MenuModel(menuGroups: menuGroupModels);
    appManager?.modifyMenuModel(menuModel);

    return menuModel;
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
    return _componentModels.where((element) => (element.parent == id)).toList();
  }

  @override
  List<FlComponentModel> getDescendantModels(String id) {
    return _componentModels
        .where((element) => (element.parent == id))
        .expand((element) => [element, ...getDescendantModels(element.id)])
        .toList();
  }

  @override
  FlComponentModel? getComponentModel({required String pComponentId}) {
    return _componentModels.firstWhereOrNull((element) => element.id == pComponentId);
  }

  @override
  FlComponentModel? getComponentByName({required String pComponentName}) {
    return _componentModels.firstWhereOrNull((element) => element.name == pComponentName);
  }

  @override
  FlPanelModel? getComponentByScreenName({required String pScreenLongName}) {
    return _componentModels.firstWhereOrNull((element) => element.screenLongName == pScreenLongName) as FlPanelModel?;
  }

  @override
  void saveNewComponents({required List<FlComponentModel> newModels}) {
    FlutterJVx.log.d("Save new components: ${newModels.map((e) => e.id).toList()}");
    _componentModels.addAll(newModels);
  }

  @override
  void closeScreen({required String pScreenName, required bool pBeamBack}) {
    FlComponentModel? screenModel = _componentModels.firstWhereOrNull((element) => element.name == pScreenName);

    if (screenModel != null) {
      List<FlComponentModel> children = getAllComponentsBelow(screenModel.id);

      // Remove all children and itself
      _componentModels.removeWhere((currentComp) =>
          currentComp == screenModel || children.any((compToDelete) => compToDelete.id == currentComp.id));

      // clear lists that get filled when new screen opens anyway
      _componentSubscriptions.removeWhere((currentComp) =>
          currentComp.compId == screenModel.id ||
          children.any((compToDelete) => compToDelete.id == currentComp.compId));
      _dataSubscriptions.removeWhere((currentComp) =>
          currentComp.id == screenModel.id || children.any((compToDelete) => compToDelete.id == currentComp.id));
    }

    if (pBeamBack) {
      FlutterJVx.getCurrentContext()!.beamBack();
    }
  }

  @override
  List<FlComponentModel> getAllComponentsBelow(String id) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in List<FlComponentModel>.from(_componentModels)) {
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
  void setLayoutPosition({required LayoutData layoutData}) {
    List<ComponentSubscription>.from(_componentSubscriptions)
        .where((element) => element.compId == layoutData.id)
        .forEach((element) {
      element.layoutCallback?.call(layoutData);
    });
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Component registration management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void registerAsLiveComponent({required ComponentSubscription pComponentSubscription}) {
    _componentSubscriptions.add(pComponentSubscription);
  }

  @override
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pShouldFetch = true}) {
    _dataSubscriptions.removeWhere((element) => element.same(pDataSubscription));
    _dataSubscriptions.add(pDataSubscription);

    if (pShouldFetch) {
      bool needFetch = IDataService().getDataBook(pDataSubscription.dataProvider) == null;

      if (needFetch) {
        sendCommand(FetchCommand(
          dataProvider: pDataSubscription.dataProvider,
          fromRow: pDataSubscription.from,
          rowCount: pDataSubscription.to != null ? pDataSubscription.to! - pDataSubscription.from : -1,
          columnNames: pDataSubscription.dataColumns,
          reason: "Fetch for ${pDataSubscription.runtimeType}",
        ));
        return;
      }

      if (pDataSubscription.from != -1 && pDataSubscription.onDataChunk != null) {
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

      if (pDataSubscription.onSelectedRecord != null) {
        GetSelectedDataCommand getSelectedDataCommand = GetSelectedDataCommand(
          subId: pDataSubscription.id,
          reason: "Subscription added",
          dataProvider: pDataSubscription.dataProvider,
          columnNames: pDataSubscription.dataColumns,
        );
        sendCommand(getSelectedDataCommand);
      }

      if (pDataSubscription.onMetaData != null) {
        GetMetaDataCommand getMetaDataCommand = GetMetaDataCommand(
          reason: "Subscription added",
          dataProvider: pDataSubscription.dataProvider,
          subId: pDataSubscription.id,
        );
        sendCommand(getMetaDataCommand);
      }
    }
  }

  @override
  void deleteInactiveComponent({required Set<String> inactiveIds}) {
    // remove subscription for removed components
    for (String inactiveId in inactiveIds) {
      _componentModels.removeWhere((screenComponent) => screenComponent.id == inactiveId);
    }
  }

  @override
  void disposeSubscriptions({required Object pSubscriber}) {
    _dataSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
    _componentSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
  }

  @override
  void disposeDataSubscription({required Object pSubscriber, String? pDataProvider}) {
    _dataSubscriptions.removeWhere((element) =>
        element.subbedObj == pSubscriber && (pDataProvider == null || element.dataProvider == pDataProvider));
  }

  @override
  List<BaseCommand> collectAllEditorSaveCommands(String? pId) {
    return List<ComponentSubscription>.from(_componentSubscriptions)
        .where((element) => element.compId != pId)
        .map((e) => e.saveCallback?.call())
        .whereNotNull()
        .toList();
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Methods to notify components about changes to themselves
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyAffectedComponents({required Set<String> affectedIds}) {
    for (String affectedId in affectedIds) {
      List<ComponentSubscription>.from(_componentSubscriptions)
          .where((element) => element.compId == affectedId)
          .forEach((element) {
        element.affectedCallback?.call();
      });
    }
  }

  @override
  void notifyChangedComponents({required List<FlComponentModel> updatedModels}) {
    for (FlComponentModel updatedModel in updatedModels) {
      // Change to new Model

      if (_componentModels.any((element) => element.id == updatedModel.id)) {
        _componentModels.removeWhere((element) => element.id == updatedModel.id);
        _componentModels.add(updatedModel);
      }

      // Notify active component
      List<ComponentSubscription>.from(_componentSubscriptions)
          .where((element) => element.compId == updatedModel.id)
          .forEach((element) {
        element.modelCallback?.call(updatedModel);
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
  CustomScreen? getCustomScreen({required String pScreenLongName}) {
    return appManager?.customScreens.firstWhereOrNull((customScreen) => customScreen.screenLongName == pScreenLongName);
  }

  @override
  CustomComponent? getCustomComponent({required String pComponentName}) {
    List<CustomScreen>? screens = appManager?.customScreens;

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

  @override
  bool usesNativeRouting({required String pScreenLongName}) {
    CustomScreen? customScreen = getCustomScreen(pScreenLongName: pScreenLongName);

    if (customScreen != null) {
      if (_hasReplaced(pScreenLongName: pScreenLongName)) {
        if (IConfigService().isOffline()) {
          // Offline + Replace => Beam
          return true;
        } else {
          // Online + Replace => can choose
          return !customScreen.sendOpenScreenRequests;
        }
      } else {
        // No Replace => Beam
        return true;
      }
    }

    // Full VisionX-Screen => Send
    return false;
  }

  bool _hasReplaced({required String pScreenLongName}) {
    return _menuModel?.menuGroups
            .any((element) => element.items.any((element) => element.screenLongName == pScreenLongName)) ??
        false;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Unsorted method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, MessageDialog> getFrames() {
    return _activeFrames;
  }

  @override
  void showFrame({
    required String componentId,
    required MessageDialog pDialog,
  }) {
    _activeFrames[componentId] = pDialog;
    JVxOverlayState.of(FlutterJVx.getCurrentContext()!)?.refreshFrames();
  }

  @override
  void closeFrame({required String componentId}) {
    _activeFrames.remove(componentId);
    JVxOverlayState.of(FlutterJVx.getCurrentContext()!)?.refreshFrames();
  }

  @override
  void closeFrames() {
    _activeFrames.clear();
    JVxOverlayState.of(FlutterJVx.getCurrentContext()!)?.refreshFrames();
  }

  @override
  List<FrameDialog> getFrameDialogs() {
    return _activeDialogs;
  }

  @override
  void showFrameDialog(FrameDialog pDialog) {
    _activeDialogs.add(pDialog);
    JVxOverlayState.of(FlutterJVx.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeFrameDialog(FrameDialog pDialog) {
    pDialog.onClose();
    _activeDialogs.remove(pDialog);
    JVxOverlayState.of(FlutterJVx.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeFrameDialogs() {
    _activeDialogs.forEach((dialog) => dialog.onClose());
    _activeDialogs.clear();
    JVxOverlayState.of(FlutterJVx.getCurrentContext())?.refreshDialogs();
  }

  @override
  void saveAllEditorsThen(String? pId, Function? pFunction, String pReason) {
    sendCommand(SaveAllEditorsCommand(componentId: pId, reason: pReason)).then((value) {
      FlutterJVx.log.i("Save all complete.");
      pFunction?.call();
    });
  }
}
