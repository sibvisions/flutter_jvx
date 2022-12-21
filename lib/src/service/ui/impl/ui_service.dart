import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../custom/app_manager.dart';
import '../../../custom/custom_component.dart';
import '../../../custom/custom_menu_item.dart';
import '../../../custom/custom_screen.dart';
import '../../../exceptions/error_view_exception.dart';
import '../../../flutter_ui.dart';
import '../../../mask/error/message_dialog.dart';
import '../../../mask/frame_dialog.dart';
import '../../../mask/jvx_overlay.dart';
import '../../../model/command/api/fetch_command.dart';
import '../../../model/command/api/login_command.dart';
import '../../../model/command/api/save_all_editors.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/get_data_chunk_command.dart';
import '../../../model/command/data/get_meta_data_command.dart';
import '../../../model/command/data/get_selected_data_command.dart';
import '../../../model/command/ui/open_error_dialog_command.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/data/subscriptions/data_subscription.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_group_model.dart';
import '../../../model/menu/menu_model.dart';
import '../../../model/response/dal_meta_data_response.dart';
import '../../../routing/locations/login_location.dart';
import '../../../routing/locations/settings_location.dart';
import '../../../util/extensions/string_extensions.dart';
import '../../command/i_command_service.dart';
import '../../config/config_service.dart';
import '../../data/i_data_service.dart';
import '../../storage/i_storage_service.dart';
import '../i_ui_service.dart';

/// Manages all interactions with the UI
class UiService implements IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unmodified menu model sent from server
  MenuModel? _originalMenuModel;

  /// Current menu model
  final ValueNotifier<MenuModel> _menuNotifier = ValueNotifier(const MenuModel());

  /// All component subscriptions
  final List<ComponentSubscription> _componentSubscriptions = [];

  /// All data subscriptions
  final List<DataSubscription> _dataSubscriptions = [];

  /// Map of all active frames (dialogs) with their componentId
  final Map<String, MessageDialog> _activeFrames = {};
  final List<FrameDialog> _activeDialogs = [];

  /// Holds all custom screen modifications
  AppManager? appManager;

  /// The currently focused object.
  String? focusedComponentId;

  /// TODO: Holds previously calculated TableSizes

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UiService.create();

  @override
  void clear() {
    _menuNotifier.value = const MenuModel();
    _componentSubscriptions.clear();
    _dataSubscriptions.clear();
    _activeFrames.clear();
    _activeDialogs.clear();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<void> sendCommand(BaseCommand command) {
    return ICommandService().sendCommand(command).catchError(handleAsyncError);
  }

  @override
  handleAsyncError(Object error, StackTrace stackTrace) {
    FlutterUI.logUI.e("Error while sending async command", error, stackTrace);

    if (error is! ErrorViewException) {
      bool isTimeout = error is TimeoutException || error is SocketException;
      ICommandService().sendCommand(OpenErrorDialogCommand(
        message: FlutterUI.translate(IUiService.getErrorMessage(error)),
        error: error,
        canBeFixedInSettings: isTimeout,
        reason: "Command error in ui service",
      ));
    }

    return null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Beaming history will be cleared when it should not be possible to go back,
  // as you should not be able to go back to the splash screen or back to menu when u logged out

  /// If we are currently in splash and never had a context before (initiated = false),
  /// then ignore route request while in settings (and later also while in work screen)
  static bool checkFirstSplash() {
    if (FlutterUI.getCurrentContext() == null && !FlutterUI.initiated) {
      // TODO fix workScreen web reload (e.g. send OpenScreenCommand); Potential Idea -> FS#3063
      if (kIsWeb && (Uri.base.fragment == "/settings" /*|| Uri.base.fragment.startsWith("/workScreen")*/)) {
        return false;
      }
    }
    return true;
  }

  @override
  void routeToMenu({bool pReplaceRoute = false}) {
    if (!checkFirstSplash()) return;

    var lastLocation = FlutterUI.getBeamerDelegate().currentBeamLocation;
    if (pReplaceRoute || lastLocation.runtimeType == SettingsLocation || lastLocation.runtimeType == LoginLocation) {
      FlutterUI.clearHistory();
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/menu");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/menu");
    }
  }

  @override
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false}) {
    if (!checkFirstSplash()) return;

    FlutterUI.logUI.i("Routing to workscreen: $pScreenName");

    var lastLocation = FlutterUI.getBeamerDelegate().currentBeamLocation;
    if (pReplaceRoute || lastLocation.runtimeType == SettingsLocation || lastLocation.runtimeType == LoginLocation) {
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/workScreen/$pScreenName");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/workScreen/$pScreenName");
    }
  }

  @override
  void routeToLogin({LoginMode? mode, Map<String, String?>? pLoginProps}) {
    if (!checkFirstSplash()) return;

    FlutterUI.clearHistory();

    FlutterUI.getBeamerDelegate().beamToReplacementNamed(
      "/login${mode != null ? "?mode=${mode.name.firstCharLower()}" : ""}",
      data: pLoginProps,
    );
  }

  @override
  void routeToSettings({bool pReplaceRoute = false}) {
    if (pReplaceRoute) {
      FlutterUI.clearHistory();
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/settings");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/settings");
    }
  }

  @override
  void routeToCustom({required String pFullPath}) {
    FlutterUI.getBeamerDelegate().beamToNamed(pFullPath);
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
  }) =>
      showDialog(
        context: context ?? FlutterUI.getCurrentContext()!,
        barrierDismissible: pIsDismissible,
        builder: (BuildContext context) => WillPopScope(
          child: pBuilder.call(context),
          onWillPop: () async => pIsDismissible,
        ),
      );

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Meta data management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  MenuModel getMenuModel() {
    return _updateMenuModel(_originalMenuModel);
  }

  @override
  ValueNotifier<MenuModel> getMenuNotifier() {
    return _menuNotifier;
  }

  @override
  void setMenuModel(MenuModel? pMenuModel) {
    _originalMenuModel = pMenuModel;
    _menuNotifier.value = _originalMenuModel ?? const MenuModel();
  }

  /// Modifies the original menu model to include custom screens and replace screens.
  ///
  /// We have to deliver it "fresh" because of the offline state change, possible solution, connect with offlineNotifier
  /// ```dart
  /// ConfigService().getOfflineNotifier().addListener(() {
  ///   _menuNotifier.value = _updateMenuModel(_originalMenuModel);
  /// });
  /// ```
  MenuModel _updateMenuModel(MenuModel? pMenuModel) {
    List<MenuGroupModel> menuGroupModels = [...?pMenuModel?.copy().menuGroups];

    // Add all custom menuItems
    if (appManager != null) {
      appManager!.customScreens.where((customScreen) => customScreen.menuItemModel != null).forEach((customScreen) {
        CustomMenuItem customMenuItem = customScreen.menuItemModel!;

        // Remove menu items that open the same screen
        menuGroupModels.forEach((menuGroup) =>
            menuGroup.items.removeWhere((menuItem) => menuItem.screenLongName == customMenuItem.screenLongName));

        if ((customScreen.showOnline && !ConfigService().isOffline()) ||
            (customScreen.showOffline && ConfigService().isOffline())) {
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
  void notifyChangedComponents({required List<String> updatedModels}) {
    for (String updatedModelId in updatedModels) {
      // Notify active component
      List<ComponentSubscription>.from(_componentSubscriptions)
          .where((element) => element.compId == updatedModelId)
          .forEach((element) {
        element.modelCallback?.call();
      });
    }
  }

  @override
  void notifyDataChange({
    required String pDataProvider,
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
  void notifyMetaDataChange({
    required String pDataProvider,
  }) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataProvider).forEach((sub) {
      // Check if selected data changed
      sendCommand(GetMetaDataCommand(
        subId: sub.id,
        reason: "Notify data was called with pFrom -1",
        dataProvider: sub.dataProvider,
      ));
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

    if (customScreen == null) {
      // Full VisionX-Screen => Send
      return false;
    }

    if (_hasReplaced(pScreenLongName: pScreenLongName)) {
      if (ConfigService().isOffline()) {
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

  bool _hasReplaced({required String pScreenLongName}) {
    return getMenuModel()
        .menuGroups
        .any((element) => element.items.any((element) => element.screenLongName == pScreenLongName));
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
    JVxOverlayState.of(FlutterUI.getCurrentContext()!)?.refreshFrames();
  }

  @override
  void closeFrame({required String componentId}) {
    _activeFrames.remove(componentId);
    JVxOverlayState.of(FlutterUI.getCurrentContext()!)?.refreshFrames();
  }

  @override
  void closeFrames() {
    _activeFrames.clear();
    JVxOverlayState.of(FlutterUI.getCurrentContext()!)?.refreshFrames();
  }

  @override
  List<FrameDialog> getFrameDialogs() {
    return _activeDialogs;
  }

  @override
  void showFrameDialog(FrameDialog pDialog) {
    _activeDialogs.add(pDialog);
    JVxOverlayState.of(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeFrameDialog(FrameDialog pDialog) {
    pDialog.onClose();
    _activeDialogs.remove(pDialog);
    JVxOverlayState.of(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeFrameDialogs() {
    _activeDialogs.forEach((dialog) => dialog.onClose());
    _activeDialogs.clear();
    JVxOverlayState.of(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  Future<void> saveAllEditors({String? pId, required String pReason, Future<List<BaseCommand>> Function()? pFunction}) {
    return ICommandService().sendCommand(
      SaveAllEditorsCommand(
        componentId: pId,
        reason: pReason,
        pFunction: pFunction,
      ),
    );
  }

  @override
  void setFocus(String pComponentId) {
    removeFocus();
    focusedComponentId = pComponentId;
  }

  @override
  bool hasFocus(String pComponentId) {
    return focusedComponentId == pComponentId;
  }

  @override
  FlComponentModel? getFocus() {
    if (focusedComponentId == null) {
      return null;
    }

    return IStorageService().getComponentModel(pComponentId: focusedComponentId!);
  }

  @override
  void removeFocus([String? pComponentId]) {
    if (pComponentId == null || hasFocus(pComponentId)) {
      focusedComponentId = null;
    }
  }
}
