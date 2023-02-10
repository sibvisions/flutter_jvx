import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
import '../../../model/command/data/get_page_chunk_command.dart';
import '../../../model/command/data/get_selected_data_command.dart';
import '../../../model/command/ui/open_error_dialog_command.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/model_subscription.dart';
import '../../../model/config/application_parameters.dart';
import '../../../model/data/data_book.dart';
import '../../../model/data/subscriptions/data_chunk.dart';
import '../../../model/data/subscriptions/data_record.dart';
import '../../../model/data/subscriptions/data_subscription.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/menu/menu_group_model.dart';
import '../../../model/menu/menu_item_model.dart';
import '../../../model/menu/menu_model.dart';
import '../../../model/response/application_meta_data_response.dart';
import '../../../model/response/application_parameters_response.dart';
import '../../../model/response/application_settings_response.dart';
import '../../../model/response/device_status_response.dart';
import '../../../routing/locations/login_location.dart';
import '../../../routing/locations/settings_location.dart';
import '../../../routing/locations/work_screen_location.dart';
import '../../../util/extensions/string_extensions.dart';
import '../../command/i_command_service.dart';
import '../../config/config_controller.dart';
import '../../data/i_data_service.dart';
import '../../storage/i_storage_service.dart';
import '../i_ui_service.dart';

/// Manages all interactions with the UI
class UiService implements IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Holds all custom screen modifications
  AppManager? appManager;

  /// Unmodified menu model sent from server
  MenuModel? _originalMenuModel;

  /// Current menu model
  final ValueNotifier<MenuModel> _menuNotifier = ValueNotifier(const MenuModel());

  /// All component subscriptions
  final List<ComponentSubscription> _componentSubscriptions = [];

  /// All model subscriptions
  final List<ModelSubscription> _modelSubscriptions = [];

  /// All data subscriptions
  final List<DataSubscription> _dataSubscriptions = [];

  /// Map of all active frames (dialogs) with their componentId
  final Map<String, MessageDialog> _activeFrames = {};
  final List<FrameDialog> _activeDialogs = [];

  /// The currently focused object.
  String? focusedComponentId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Runtime related fields (e.g. responses from the server)
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Current clientId (sessionId).
  final ValueNotifier<String?> _clientId = ValueNotifier(null);

  /// The last layoutMode from the server.
  final ValueNotifier<LayoutMode> _layoutMode = ValueNotifier(kIsWeb ? LayoutMode.Full : LayoutMode.Mini);

  /// JVx Application Settings.
  final ValueNotifier<ApplicationSettingsResponse> _applicationSettings =
      ValueNotifier(ApplicationSettingsResponse.empty());

  /// JVx Application Parameters.
  final ValueNotifier<ApplicationParameters?> _applicationParameters = ValueNotifier(null);

  /// JVx Application Metadata.
  final ValueNotifier<ApplicationMetaDataResponse?> _applicationMetaData = ValueNotifier(null);

  final ValueNotifier<bool> _mobileOnly = ValueNotifier(false);

  final ValueNotifier<bool> _webOnly = ValueNotifier(false);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UiService.create();

  @override
  FutureOr<void> clear(bool pFullClear) {
    _menuNotifier.value = const MenuModel();
    _componentSubscriptions.clear();
    _modelSubscriptions.clear();
    _dataSubscriptions.clear();
    _activeFrames.clear();
    _activeDialogs.clear();

    if (pFullClear) {
      _clientId.value = null;
      _layoutMode.value = kIsWeb ? LayoutMode.Full : LayoutMode.Mini;
      _applicationSettings.value = ApplicationSettingsResponse.empty();
      _applicationParameters.value = null;
      _applicationMetaData.value = null;
    }
  }

  @override
  MenuItemModel? getMenuItem(String pScreenName) {
    return getMenuModel()
        .menuGroups
        .expand((group) => group.items)
        .firstWhereOrNull((item) => item.matchesScreenName(pScreenName));
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
  static bool checkFirstSplash([bool includeWorkScreens = true]) {
    if (FlutterUI.getCurrentContext() == null && !FlutterUI.initiated) {
      if (kIsWeb &&
          (Uri.base.fragment == "/settings" || (includeWorkScreens && Uri.base.fragment.startsWith("/workScreen")))) {
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

    MenuItemModel? menuItemModel = getMenuItem(pScreenName);
    String resolvedScreenName = menuItemModel?.navigationName ?? pScreenName;
    FlutterUI.logUI.i("Routing to workscreen: $pScreenName, resolved name: $resolvedScreenName");

    var lastLocation = FlutterUI.getBeamerDelegate().currentBeamLocation;
    if (pReplaceRoute || lastLocation.runtimeType == SettingsLocation || lastLocation.runtimeType == LoginLocation) {
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/workScreen/$resolvedScreenName");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/workScreen/$resolvedScreenName");
    }
  }

  @override
  void routeToLogin({LoginMode? mode, Map<String, dynamic>? pLoginProps}) {
    if (!checkFirstSplash(false)) return;

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
  /// [CustomMenuItem]'s are included by either:
  /// * Using the one provided by [AppManager.customMenuItems].
  /// * Using the one from the original replaced screen (only works if there is one).
  /// * And lastly creates one on a best-effort strategy (It is recommended to provide one).
  ///
  /// We have to deliver it "fresh" because of the offline state change, possible solution, connect with offlineNotifier
  /// ```dart
  /// ConfigController().getOfflineNotifier().addListener(() {
  ///   _menuNotifier.value = _updateMenuModel(_originalMenuModel);
  /// });
  /// ```
  MenuModel _updateMenuModel(MenuModel? pMenuModel) {
    List<MenuGroupModel> menuGroupModels = [...?pMenuModel?.copy().menuGroups];

    if (appManager != null) {
      appManager!.customScreens.forEach((customScreen) {
        CustomMenuItem? customMenuItem = appManager!.customMenuItems[customScreen.key];

        // Check for screen replacing by retrieving every menu item who open the same screen.
        Iterable<Iterable<MenuItemModel>> it = menuGroupModels.map((e) => e.items).map((menuItems) => menuItems
            .where((menuItem) => [menuItem.screenLongName, menuItem.navigationName].contains(customScreen.key)));
        // This is usually just one item.
        List<MenuItemModel> items = it.isNotEmpty ? it.reduce((value, element) => [...value, ...element]).toList() : [];

        if (items.isNotEmpty) {
          // We have an menu item that we can replace.
          // if (customMenuItem == null) {
          //   customMenuItem ??= CustomMenuItem(
          //     group: items.firstOrNull?.name ?? "Custom",
          //     label: customScreen.screenTitle ?? "Custom Screen",
          //     faIcon: FontAwesomeIcons.notdef,
          //   );
          // }
        } else {
          // We have no menu item, use the one provided or create one on best-effort basis.
          customMenuItem ??= CustomMenuItem(
            group: menuGroupModels.firstOrNull?.name ?? "Custom",
            label: customScreen.screenTitle ?? "Custom Screen",
            faIcon: FontAwesomeIcons.notdef,
          );
        }

        // Whether we should show the item in the current setting.
        if ((customScreen.showOnline && !ConfigController().offline.value) ||
            (customScreen.showOffline && ConfigController().offline.value)) {
          // At this point we either have a custom menu item or an original one.
          MenuItemModel? originalItem = items.firstOrNull;

          MenuItemModel overrideMenuItem = MenuItemModel(
            screenLongName: originalItem?.screenLongName ?? customScreen.key,
            navigationName: originalItem?.navigationName ?? customScreen.keyNavigationName,
            label: customMenuItem?.label ?? originalItem!.label,
            alternativeLabel: customMenuItem?.alternativeLabel ?? originalItem?.alternativeLabel,
            imageBuilder: customMenuItem?.imageBuilder,
            // Only override image if there is no image builder.
            image: customMenuItem?.imageBuilder == null ? originalItem?.image : null,
          );

          // Check if group already exists.
          MenuGroupModel? menuGroupModel = customMenuItem?.group != null
              // Custom group doesn't have to exist
              ? menuGroupModels.firstWhereOrNull((element) => element.name == customMenuItem!.group)
              : menuGroupModels.firstWhere((element) => items.any((item) => item == originalItem));

          if (menuGroupModel == null) {
            // Make new group if it didn't exist.
            menuGroupModel = MenuGroupModel(
              name: customMenuItem!.group,
              items: [],
            );
            menuGroupModels.add(menuGroupModel);
          }
          menuGroupModel.items.add(overrideMenuItem);
        }

        if (customMenuItem != null) {
          // Finally remove menu items that we replaced.
          menuGroupModels.forEach((menuGroup) => menuGroup.items.removeWhere((menuItem) => items.contains(menuItem)));
        }
      });
    }

    MenuModel menuModel = MenuModel(menuGroups: menuGroupModels);

    appManager?.modifyMenuModel(menuModel);

    return menuModel;
  }

  @override
  ValueNotifier<String?> get clientId => _clientId;

  @override
  void updateClientId(String? pClientId) {
    _clientId.value = pClientId;
  }

  @override
  ValueNotifier<ApplicationMetaDataResponse?> get applicationMetaData => _applicationMetaData;

  @override
  void updateApplicationMetaData(ApplicationMetaDataResponse? pApplicationMetaData) {
    _applicationMetaData.value = pApplicationMetaData;
  }

  @override
  ValueNotifier<ApplicationSettingsResponse> get applicationSettings => _applicationSettings;

  @override
  void updateApplicationSettings(ApplicationSettingsResponse pApplicationSettings) {
    _applicationSettings.value = pApplicationSettings;
  }

  @override
  ValueNotifier<ApplicationParameters?> get applicationParameters => _applicationParameters;

  @override
  void updateApplicationParameters(ApplicationParametersResponse pApplicationParameters) {
    _applicationParameters.value =
        const ApplicationParameters.empty().merge(_applicationParameters.value).mergeResponse(pApplicationParameters);
  }

  @override
  ValueNotifier<LayoutMode> get layoutMode => _layoutMode;

  @override
  void updateLayoutMode(LayoutMode pLayoutMode) {
    _layoutMode.value = pLayoutMode;
  }

  @override
  ValueNotifier<bool> get mobileOnly => _mobileOnly;

  @override
  void updateMobileOnly(bool pMobileOnly) {
    _mobileOnly.value = pMobileOnly;
  }

  @override
  ValueNotifier<bool> get webOnly => _webOnly;

  @override
  void updateWebOnly(bool pWebOnly) {
    _webOnly.value = pWebOnly;
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
  void registerModelSubscription(ModelSubscription pModelSubscription) {
    _modelSubscriptions.add(pModelSubscription);
  }

  @override
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pShouldFetch = true}) {
    _dataSubscriptions.removeWhere((element) => element.same(pDataSubscription));
    _dataSubscriptions.add(pDataSubscription);

    if (pShouldFetch) {
      DataBook? databook = IDataService().getDataBook(pDataSubscription.dataProvider);

      if (databook == null) {
        sendCommand(FetchCommand(
          dataProvider: pDataSubscription.dataProvider,
          fromRow: pDataSubscription.from,
          rowCount: pDataSubscription.to != null
              ? pDataSubscription.to! - pDataSubscription.from
              : IUiService().getSubscriptionRowcount(pDataProvider: pDataSubscription.dataProvider),
          columnNames: pDataSubscription.dataColumns,
          reason: "Fetch for ${pDataSubscription.runtimeType}",
          includeMetaData: true,
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

      if (pDataSubscription.onReload != null) {
        databook.pageRecords.keys.forEach((pageKey) {
          GetPageChunkCommand getDataChunkCommand = GetPageChunkCommand(
            reason: "Subscription added",
            dataProvider: pDataSubscription.dataProvider,
            from: pDataSubscription.from,
            to: pDataSubscription.to,
            subId: pDataSubscription.id,
            pageKey: pageKey,
          );
          sendCommand(getDataChunkCommand);
        });
      }
    }
  }

  @override
  void notifySubscriptionsOfReload({required String pDataprovider}) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataprovider).forEach((dataSubscription) {
      if (dataSubscription.onReload != null && dataSubscription.onDataChunk != null && dataSubscription.from >= 0) {
        dataSubscription.to = dataSubscription.onReload!.call(IDataService().getDataBook(pDataprovider)!.selectedRow);
      }
    });
  }

  @override
  void disposeSubscriptions({required Object pSubscriber}) {
    _dataSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
    _componentSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
    _modelSubscriptions.removeWhere((element) => element.subbedObj == pSubscriber);
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
  void notifyModels() {
    List<FlComponentModel> models = IStorageService().getComponentModels();
    for (var sub in _modelSubscriptions) {
      var model = models.firstWhereOrNull((model) => sub.check.call(model));
      if (model != null && sub.check.call(model)) {
        sub.onNewModel.call(model);
      }
    }
  }

  @override
  void notifyDataChange({
    required String pDataProvider,
    bool pUpdatedRecords = true,
    String? pUpdatedPage,
  }) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataProvider).forEach((sub) {
      // Check if selected data changed
      if (pUpdatedPage != null) {
        if (sub.onPage != null) {
          sendCommand(GetPageChunkCommand(
            reason: "Notify data was called",
            dataProvider: pDataProvider,
            from: sub.from,
            to: sub.to,
            subId: sub.id,
            pageKey: pUpdatedPage,
          ));
        }
      }
      if (pUpdatedRecords) {
        if (sub.onSelectedRecord != null) {
          sendCommand(GetSelectedDataCommand(
            subId: sub.id,
            reason: "Notify data was called with pFrom -1",
            dataProvider: sub.dataProvider,
            columnNames: sub.dataColumns,
          ));
        }
        if (sub.from != -1 && sub.onDataChunk != null) {
          sendCommand(GetDataChunkCommand(
            reason: "Notify data was called",
            dataProvider: pDataProvider,
            from: sub.from,
            to: sub.to,
            subId: sub.id,
            dataColumns: sub.dataColumns,
          ));
        }
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
  void sendSubsSelectedData({
    required String pSubId,
    required String pDataProvider,
    required DataRecord? pDataRow,
  }) {
    _dataSubscriptions
        .where((element) => element.dataProvider == pDataProvider && element.id == pSubId)
        .forEach((element) => element.onSelectedRecord?.call(pDataRow));
  }

  @override
  void sendSubsDataChunk({
    required String pSubId,
    required DataChunk pDataChunk,
    required String pDataProvider,
  }) {
    List<DataSubscription> subs =
        _dataSubscriptions.where((element) => element.dataProvider == pDataProvider && element.id == pSubId).toList();

    subs.forEach((element) {
      element.onDataChunk?.call(pDataChunk);
    });
  }

  @override
  void sendSubsPageChunk({
    required String pSubId,
    required String pDataProvider,
    required DataChunk pDataChunk,
    required String pPageKey,
  }) {
    List<DataSubscription> subs =
        _dataSubscriptions.where((element) => element.dataProvider == pDataProvider && element.id == pSubId).toList();

    subs.forEach((element) {
      element.onPage?.call(pPageKey, pDataChunk);
    });
  }

  @override
  void sendSubsMetaData({
    required String pSubId,
    required String pDataProvider,
    required DalMetaData pMetaData,
  }) {
    _dataSubscriptions
        .where((sub) => sub.dataProvider == pDataProvider && sub.id == pSubId && sub.onMetaData != null)
        .forEach((element) {
      element.onMetaData!(pMetaData);
    });
  }

  @override
  int getSubscriptionRowcount({required String pDataProvider}) {
    int rowCount = 0;

    var subscriptions = _dataSubscriptions.where((sub) => sub.dataProvider == pDataProvider);
    for (DataSubscription subscription in subscriptions) {
      rowCount = max(rowCount, subscription.to ?? 0);
    }

    return rowCount;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  CustomScreen? getCustomScreen(String key) {
    return appManager?.customScreens.firstWhereOrNull((customScreen) => customScreen.key == key);
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
  bool usesNativeRouting(String pScreenLongName) {
    CustomScreen? customScreen = getCustomScreen(pScreenLongName);

    if (customScreen == null) {
      // Full VisionX-Screen => Send
      return false;
    }

    if (_hasReplaced(pScreenLongName)) {
      if (ConfigController().offline.value) {
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

  bool _hasReplaced(String pScreenLongName) {
    return _originalMenuModel?.containsScreen(pScreenLongName) ?? false;
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
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshFrames();
  }

  @override
  void closeFrame({required String componentId}) {
    _activeFrames.remove(componentId);
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshFrames();
  }

  @override
  void closeFrames() {
    _activeFrames.clear();
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshFrames();
  }

  @override
  List<FrameDialog> getFrameDialogs() {
    return _activeDialogs;
  }

  @override
  void showFrameDialog(FrameDialog pDialog) {
    _activeDialogs.add(pDialog);
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeFrameDialog(FrameDialog pDialog) {
    pDialog.onClose();
    _activeDialogs.remove(pDialog);
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeFrameDialogs() {
    _activeDialogs.forEach((dialog) => dialog.onClose());
    _activeDialogs.clear();
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
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

  @override
  String? getCurrentWorkscreenName() {
    if (FlutterUI.getBeamerDelegate().currentBeamLocation.runtimeType != WorkScreenLocation) {
      return null;
    }
    return (FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState).pathParameters['workScreenName'];
  }
}
