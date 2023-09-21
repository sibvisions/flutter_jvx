import 'dart:async';
import 'dart:io';
import 'dart:math' hide log;

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../custom/app_manager.dart';
import '../../../custom/custom_component.dart';
import '../../../custom/custom_menu_item.dart';
import '../../../custom/custom_screen.dart';
import '../../../exceptions/error_view_exception.dart';
import '../../../exceptions/session_expired_exception.dart';
import '../../../flutter_ui.dart';
import '../../../mask/error/message_dialog.dart';
import '../../../mask/frame/frame.dart';
import '../../../mask/frame_dialog.dart';
import '../../../mask/jvx_overlay.dart';
import '../../../mask/work_screen/content.dart';
import '../../../model/command/api/close_content_command.dart';
import '../../../model/command/api/feedback_command.dart';
import '../../../model/command/api/fetch_command.dart';
import '../../../model/command/api/save_all_editors.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/data/get_data_chunk_command.dart';
import '../../../model/command/data/get_meta_data_command.dart';
import '../../../model/command/data/get_page_chunk_command.dart';
import '../../../model/command/data/get_selected_data_command.dart';
import '../../../model/command/ui/function_command.dart';
import '../../../model/command/ui/open_error_dialog_command.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/model_subscription.dart';
import '../../../model/config/application_parameters.dart';
import '../../../model/config/translation/i18n.dart';
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
import '../../../routing/locations/main_location.dart';
import '../../../util/jvx_colors.dart';
import '../../apps/i_app_service.dart';
import '../../command/i_command_service.dart';
import '../../config/i_config_service.dart';
import '../../data/i_data_service.dart';
import '../../layout/i_layout_service.dart';
import '../../service.dart';
import '../../storage/i_storage_service.dart';
import '../i_ui_service.dart';

/// Manages all interactions with the UI.
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
  final List<JVxDialog> _activeDialogs = [];

  /// Map of all active content widgets with their name
  final List<String> _activeContents = [];

  /// The currently focused object.
  String? focusedComponentId;

  /// Provides translations.
  final I18n _i18n = I18n();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Runtime related fields (e.g. responses from the server)
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Current clientId (sessionId).
  final ValueNotifier<String?> _clientId = ValueNotifier(null);

  /// The last layoutMode from the server.
  final ValueNotifier<LayoutMode> _layoutMode = ValueNotifier(kIsWeb ? LayoutMode.Full : LayoutMode.Mini);

  /// JVx Application Settings.
  final ValueNotifier<ApplicationSettingsResponse> _applicationSettings =
      ValueNotifier(ApplicationSettingsResponse.defaults());

  /// JVx Application Parameters.
  final ValueNotifier<ApplicationParameters> _applicationParameters = ValueNotifier(ApplicationParameters());

  /// JVx Application Metadata.
  final ValueNotifier<ApplicationMetaDataResponse?> _applicationMetaData = ValueNotifier(null);

  final ValueNotifier<bool> _mobileOnly = ValueNotifier(false);

  final ValueNotifier<bool> _webOnly = ValueNotifier(false);

  final ValueNotifier<bool> _designMode = ValueNotifier(true);

  final ValueNotifier<String?> _designModeElement = ValueNotifier(null);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UiService.create();

  @override
  FutureOr<void> clear(ClearReason reason) async {
    await JVxOverlay.maybeOf(FlutterUI.getEffectiveContext())?.clear(reason);

    setMenuModel(null);
    _componentSubscriptions.clear();
    _modelSubscriptions.clear();
    _dataSubscriptions.clear();
    _activeDialogs.clear();

    if (reason.isFull()) {
      _clientId.value = null;
      _layoutMode.value = kIsWeb ? LayoutMode.Full : LayoutMode.Mini;
      _applicationSettings.value = ApplicationSettingsResponse.defaults();
      _applicationParameters.value = ApplicationParameters();
      _applicationMetaData.value = null;
      _designMode.value = false;
    }
  }

  @override
  MenuItemModel? getMenuItem(String pScreenName) {
    return getMenuModel()
        .menuGroups
        .expand((group) => group.items)
        .firstWhereOrNull((item) => item.matchesScreenName(pScreenName));
  }

  @override
  I18n i18n() => _i18n;

  @override
  ValueListenable<bool> get designMode {
    return _designMode;
  }

  @override
  void updateDesignMode(bool designMode) {
    _designMode.value = designMode;
  }

  @override
  ValueListenable<String?> get designModeElement {
    return _designModeElement;
  }

  @override
  void updateDesignModeElement(String? pId) {
    _designModeElement.value = pId;
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
    FlutterUI.logUI.e("Error while handling async", error: error, stackTrace: stackTrace);

    if (error is! ErrorViewException && error is! SessionExpiredException) {
      bool isTimeout = error is TimeoutException || error is SocketException;
      ICommandService()
          .sendCommand(OpenErrorDialogCommand(
            message: FlutterUI.translate(IUiService.getErrorMessage(error)),
            error: error,
            canBeFixedInSettings: isTimeout,
            reason: "UIService async error",
          ))
          .catchError(
              (e, stack) => FlutterUI.logUI.e("Another error while handling async error", error: e, stackTrace: stack));

      // If there is a current session and a "probably" working connection, report to the server.
      if (!isTimeout && IUiService().clientId.value != null) {
        ICommandService()
            .sendCommand(FeedbackCommand(
              properties: {
                "message": IUiService.getErrorMessage(error),
                "error": error,
              },
              reason: "UIService async error",
            ))
            .catchError(
                (e, stack) => FlutterUI.logUI.e("Failed to send feedback to server", error: e, stackTrace: stack));
      }
    }

    return null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Beaming history will be cleared when it should not be possible to go back,
  // as you should not be able to go back to the splash screen or back to menu when u logged out

  @override
  void routeToMenu({bool pReplaceRoute = false}) {
    var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    if (pReplaceRoute ||
        lastBeamState.pathPatternSegments.contains("settings") ||
        lastBeamState.pathPatternSegments.contains("login")) {
      FlutterUI.clearHistory();
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/home");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/home");
    }
  }

  @override
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false}) {
    var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    // Don't route if we are already there (can create history duplicates when using query parameters; e.g. in deep links)
    if (lastBeamState.pathParameters[MainLocation.screenNameKey] == pScreenName) {
      return;
    }

    MenuItemModel? menuItemModel = getMenuItem(pScreenName);
    String resolvedScreenName = menuItemModel?.navigationName ?? pScreenName;

    // Clear the history of the screen we are going to so we don't jump back into the history.
    if (!kIsWeb) {
      FlutterUI.getBeamerDelegate().beamingHistory.whereType<MainLocation>().forEach((location) {
        location.history
            .removeWhere((element) => element.routeInformation.location?.endsWith(resolvedScreenName) ?? false);
      });
    }

    FlutterUI.logUI.i("Routing to workscreen: $pScreenName, resolved name: $resolvedScreenName");

    if (pReplaceRoute ||
        lastBeamState.pathPatternSegments.contains("settings") ||
        lastBeamState.pathPatternSegments.contains("login")) {
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/screens/$resolvedScreenName");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/screens/$resolvedScreenName");
    }
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
  Future<void> routeToAppOverview() async {
    // First fire the future, then route.
    // Otherwise, the BeamGuard routing check would fail.
    var stopApp = IAppService().stopApp();

    FlutterUI.clearHistory();
    FlutterUI.getBeamerDelegate().beamToReplacementNamed("/");

    await stopApp;
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
  MenuModel? getOriginalMenuModel() {
    return _originalMenuModel;
  }

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

  @override
  bool loggedIn() {
    return IConfigService().currentApp.value != null &&
        getOriginalMenuModel() != null &&
        IConfigService().userInfo.value != null;
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
    List<MenuGroupModel> menuGroupModels = [];

    if (!IConfigService().offline.value && pMenuModel != null) {
      menuGroupModels.addAll(pMenuModel.copy().menuGroups);
    }

    if (appManager != null) {
      appManager!.customScreens.forEach((customScreen) {
        CustomMenuItem? customMenuItem = appManager!.customMenuItems[customScreen.key];

        MenuItemModel? originalItem = menuGroupModels
            .expand((element) => element.items)
            .where((menuItem) => [menuItem.navigationName, menuItem.screenLongName].contains(customScreen.key))
            .firstOrNull;

        if (originalItem == null && customMenuItem == null && customScreen.screenBuilder != null) {
          // We have no menu item, therefore, create one on best-effort basis.
          customMenuItem = CustomMenuItem(
            group: "Custom",
            label: customScreen.screenTitle ?? "Custom Screen",
            faIcon: FontAwesomeIcons.notdef,
          );
        }

        // Whether we should show the item in the current setting.
        if (customMenuItem != null &&
            ((customScreen.showOnline && !IConfigService().offline.value) ||
                (customScreen.showOffline && IConfigService().offline.value))) {
          MenuItemModel overrideMenuItem = MenuItemModel(
            screenLongName: originalItem?.screenLongName ?? customScreen.key,
            navigationName: originalItem?.navigationName ?? customScreen.keyNavigationName,
            label: customMenuItem.label,
            alternativeLabel: customMenuItem.alternativeLabel ?? originalItem?.alternativeLabel,
            imageBuilder: customMenuItem.imageBuilder,
            // Only override image if there is no image builder.
            image: customMenuItem.imageBuilder == null ? originalItem?.image : null,
          );

          // Check if group already exists.
          MenuGroupModel? menuGroupModel =
              menuGroupModels.firstWhereOrNull((element) => element.name == customMenuItem!.group);

          if (menuGroupModel == null) {
            // Make new group if it didn't exist.
            menuGroupModel = MenuGroupModel(
              name: customMenuItem.group,
              items: [],
            );
            menuGroupModels.add(menuGroupModel);
          }

          menuGroupModel.items.add(overrideMenuItem);

          // Finally remove menu items that we replaced.
          menuGroupModels.forEach((menuGroup) => menuGroup.items.remove(originalItem));
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
  ValueNotifier<ApplicationParameters> get applicationParameters => _applicationParameters;

  @override
  void updateApplicationParameters(ApplicationParametersResponse pApplicationParameters) {
    var oldAppParam = _applicationParameters.value;
    var newAppParam = ApplicationParameters(
      applicationTitleName: oldAppParam.applicationTitleName,
      applicationTitleWeb: oldAppParam.applicationTitleWeb,
      designModeAllowed: oldAppParam.designModeAllowed,
      parameters: oldAppParam.parameters,
    )..applyResponse(pApplicationParameters);

    getAppManager()?.modifyApplicationParameters(newAppParam);

    _applicationParameters.value = newAppParam;
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
    // Copy list to avoid concurrent modification
    List.of(_componentSubscriptions).where((element) => element.compId == layoutData.id).forEach((element) {
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
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pImmediatlyRetrieveData = true}) {
    _dataSubscriptions.removeWhere((element) => element.same(pDataSubscription));
    _dataSubscriptions.add(pDataSubscription);

    if (pImmediatlyRetrieveData) {
      DataBook? databook = IDataService().getDataBook(pDataSubscription.dataProvider);
      bool needsToFetch = IDataService().databookNeedsFetch(
        pFrom: pDataSubscription.from,
        pTo: pDataSubscription.to,
        pDataProvider: pDataSubscription.dataProvider,
      );
      bool fetchMetaData = databook?.metaData == null;

      if (needsToFetch || fetchMetaData) {
        int fromRow = databook?.records.keys.maxOrNull ?? pDataSubscription.from;

        sendCommand(FetchCommand(
          dataProvider: pDataSubscription.dataProvider,
          fromRow: fromRow,
          rowCount: pDataSubscription.to != null
              ? pDataSubscription.to! - pDataSubscription.from
              : IUiService().getSubscriptionRowcount(pDataProvider: pDataSubscription.dataProvider),
          reason: "Fetch for ${pDataSubscription.runtimeType}",
          includeMetaData: fetchMetaData,
        ));
      } else {
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
      }

      if (pDataSubscription.onPage != null) {
        databook?.pageRecords.keys.forEach((pageKey) {
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

      if (!fetchMetaData && pDataSubscription.onMetaData != null) {
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
  void notifySubscriptionsOfReload({required String pDataprovider}) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataprovider).toList().forEach((dataSubscription) {
      if (dataSubscription.onReload != null && dataSubscription.onDataChunk != null && dataSubscription.from >= 0) {
        dataSubscription.to = dataSubscription.onReload!.call();
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
  Future<List<BaseCommand>> collectAllEditorSaveCommands(String? pId) async {
    // Copy list to avoid concurrent modification
    List<BaseCommand> saveCommands = [];

    List<ComponentSubscription> listOfSubs =
        List.of(_componentSubscriptions).where((element) => element.compId != pId).toList();

    for (var sub in listOfSubs) {
      var command = await sub.saveCallback?.call();
      if (command != null) {
        saveCommands.add(command);
      }
    }

    return saveCommands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyAffectedComponents({required Set<String> affectedIds}) {
    for (String affectedId in affectedIds) {
      // Copy list to avoid concurrent modification
      List.of(_componentSubscriptions).where((element) => element.compId == affectedId).forEach((element) {
        element.affectedCallback?.call();
      });
    }
  }

  @override
  void notifyChangedComponents({required List<String> updatedModels}) {
    for (String updatedModelId in updatedModels) {
      // Copy list to avoid concurrent modification
      List.of(_componentSubscriptions).where((element) => element.compId == updatedModelId).forEach((element) {
        // Notify active component
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
    bool pUpdatedCurrentPage = true,
    String? pUpdatedPage,
  }) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataProvider).toList().forEach((sub) {
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
      if (pUpdatedCurrentPage) {
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
  void notifyDataToDisplayMapChanged({required String pDataProvider}) {
    _dataSubscriptions
        .where((sub) => sub.dataProvider == pDataProvider && sub.onDataToDisplayMapChanged != null)
        .toList()
        .forEach((sub) {
      sub.onDataToDisplayMapChanged?.call();
    });
  }

  @override
  void notifySelectionChange({
    required String pDataProvider,
  }) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataProvider).toList().forEach((sub) {
      if (sub.onSelectedRecord != null) {
        sendCommand(GetSelectedDataCommand(
          subId: sub.id,
          reason: "Notify data was called with pFrom -1",
          dataProvider: sub.dataProvider,
          columnNames: sub.dataColumns,
        ));
      }
    });
  }

  @override
  void notifyMetaDataChange({
    required String pDataProvider,
  }) {
    _dataSubscriptions.where((element) => element.dataProvider == pDataProvider).toList().forEach((sub) {
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
        .toList()
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
        .toList()
        .forEach((element) {
      element.onMetaData!(pMetaData);
    });
  }

  @override
  int getSubscriptionRowcount({required String pDataProvider}) {
    int rowCount = 0;

    var subscriptions = _dataSubscriptions.where((sub) => sub.dataProvider == pDataProvider).toList();
    for (DataSubscription subscription in subscriptions) {
      if (subscription.to == null) {
        return -1;
      }
      rowCount = max(rowCount, subscription.to!);
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
      if (IConfigService().offline.value) {
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
  List<JVxDialog> getJVxDialogs() {
    return _activeDialogs;
  }

  @override
  void showJVxDialog(JVxDialog pDialog) {
    if (pDialog is! MessageDialog ||
        _activeDialogs.none(
            (element) => element is MessageDialog && element.command.componentId == pDialog.command.componentId)) {
      _activeDialogs.add(pDialog);
      JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
    }
  }

  @override
  void closeJVxDialog(JVxDialog pDialog) {
    _activeDialogs.remove(pDialog);
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeMessageDialog({required String componentId}) {
    _activeDialogs.removeWhere((element) => element is MessageDialog && element.command.componentId == componentId);
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeJVxDialogs() {
    _activeDialogs.clear();
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  Future<void> saveAllEditors({String? pId, required String pReason, CommandCallback? pFunction}) {
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
    return (FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState)
        .pathParameters[MainLocation.screenNameKey];
  }

  @override
  bool isContentVisible(String pContentName) {
    return _activeContents.contains(pContentName) &&
        FlutterUI.of(FlutterUI.getCurrentContext()!).jvxRouteObserver.knownRoutes.firstWhereOrNull(
                (element) => element.settings.name == (Content.ROUTE_SETTINGS_PREFIX + pContentName)) !=
            null;
  }

  @override
  void openContent(String pContentName) {
    if (_activeContents.contains(pContentName)) {
      return;
    }

    FlComponentModel? panelModel = IStorageService().getComponentByName(pComponentName: pContentName);
    if (panelModel == null || panelModel is! FlPanelModel) {
      FlutterUI.logUI.e("Tried to open a content which is not panel!", stackTrace: StackTrace.current);
      return;
    }

    RouteSettings routeSettings = RouteSettings(
      name: Content.ROUTE_SETTINGS_PREFIX + pContentName,
    );

    _activeContents.add(pContentName);
    if (Frame.isWebFrame()) {
      showDialog(
        context: FlutterUI.getCurrentContext()!,
        builder: (context) => ContentDialog(
          model: panelModel,
        ),
        routeSettings: routeSettings,
      );
    } else {
      showBarModalBottomSheet(
        context: FlutterUI.getCurrentContext()!,
        builder: (context) => ContentBottomSheet(
          model: panelModel,
        ),
        barrierColor: JVxColors.LIGHTER_BLACK.withOpacity(0.75),
        topControl: Container(
          height: 20,
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 6,
            width: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(6)),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(topLeft: kDefaultBarTopRadius, topRight: kDefaultBarTopRadius),
        ),
        enableDrag: true,
        expand: true,
        bounce: false,
        settings: routeSettings,
      );
    }
  }

  @override
  Future<void> closeContent(String pContentName, [bool pSendClose = true]) async {
    if (!_activeContents.contains(pContentName)) {
      return;
    }

    FlComponentModel? panelModel = IStorageService().getComponentByName(pComponentName: pContentName);
    if (panelModel == null || panelModel is! FlPanelModel) {
      FlutterUI.logUI.e("Tried to close a content which is not panel!", stackTrace: StackTrace.current);
      return;
    }

    _activeContents.remove(pContentName);

    Route? route = FlutterUI.maybeOf(FlutterUI.getCurrentContext()!)
        ?.jvxRouteObserver
        .knownRoutes
        .firstWhereOrNull((element) => element.settings.name == (Content.ROUTE_SETTINGS_PREFIX + pContentName));

    if (route != null) {
      if (route.isCurrent) {
        Navigator.pop(FlutterUI.getCurrentContext()!);
      } else {
        Navigator.of(FlutterUI.getCurrentContext()!).removeRoute(route);
      }
    }

    if (pSendClose) {
      unawaited(IUiService().sendCommand(CloseContentCommand(componentName: pContentName, reason: "I got closed")));
    }
    IStorageService().deleteScreen(screenName: pContentName);
    await ILayoutService().deleteScreen(pComponentId: panelModel.id);
  }
}
