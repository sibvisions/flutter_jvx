import 'dart:async';
import 'dart:math' hide log;

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../commands.dart';
import '../../../custom/app_manager.dart';
import '../../../custom/custom_component.dart';
import '../../../custom/custom_menu_item.dart';
import '../../../custom/custom_screen.dart';
import '../../../flutter_ui.dart';
import '../../../mask/error/ierror.dart';
import '../../../mask/error/message_dialog.dart';
import '../../../mask/frame/frame.dart';
import '../../../mask/jvx_dialog.dart';
import '../../../mask/jvx_overlay.dart';
import '../../../mask/work_screen/content.dart';
import '../../../model/command/api/close_content_command.dart';
import '../../../model/command/data/get_page_chunk_command.dart';
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
import '../../apps/app.dart';
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

  /// Modified menu model
  MenuModel? _menuModel;

  /// Current menu model
  final ValueNotifier<MenuModel> _menuNotifier = ValueNotifier(MenuModel());

  /// All component subscriptions
  final List<ComponentSubscription> _componentSubscriptions = [];

  /// All model subscriptions
  final List<ModelSubscription> _modelSubscriptions = [];

  /// All data subscriptions
  final List<DataSubscription> _dataSubscriptions = [];

  /// All application parameter changed listeners
  final List<ApplicationParameterChangedListener> _appParameterListener = [];

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

    clearMenuModel();
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
        location.history.removeWhere((element) {
          return element.routeInformation.uri.toString().endsWith(resolvedScreenName);});
      });
    }

    FlutterUI.logUI.i("Routing to work-screen: $pScreenName, resolved name: $resolvedScreenName");

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
    if (IAppService().exitFuture.value != null) {
      return;
    }

    // First fire the future, then route.
    // Otherwise, the BeamGuard routing check would fail.
    var stopApp = IAppService().stopApp();

    FlutterUI.clearHistory();
    FlutterUI.getBeamerDelegate().beamToReplacementNamed("/");

    await stopApp;
  }

  @override
  bool canRouteToAppOverview() {
    IConfigService serv = IConfigService();

    if (serv.getAppConfig()!.customAppsAllowed!) {
      return true;
    }

    if (serv.isSingleAppMode()) {
      App? app = IAppService().getCurrentApp();
      if (app?.predefined == false) {
        //If app is manually defined -> route back possible
        return true;
      }
      else if (serv.getAppConfig()?.predefinedConfigsLocked == false) {
        //If app is predefined but if config is not locked -> route back possible
        return true;
      }

      return false;
    } else if (IAppService().getAppIds().length > 1) {
      return true;
    } else if (serv.getAppConfig()?.predefinedConfigsLocked == true ||
        serv.getAppConfig()?.predefinedConfigsParametersHidden == true) {
      return false;
    }

    return true;
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
        builder: (BuildContext context) => PopScope(
          canPop: pIsDismissible,
          child: pBuilder.call(context),
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
    _menuModel ??= MenuModel();

    return _menuModel!;
  }

  @override
  ValueNotifier<MenuModel> getMenuNotifier() {
    return _menuNotifier;
  }

  @override
  void setMenuModel(MenuModel? pMenuModel) {
    _originalMenuModel = pMenuModel;

    //modify only once
    _menuModel = _updateMenuModel(_originalMenuModel);

    _menuNotifier.value = _menuModel!;
  }

  @override
  void clearMenuModel() {
    _originalMenuModel = null;

    _menuModel = MenuModel();
    _menuNotifier.value = _menuModel!;
  }

  @override
  bool loggedIn() {
    return IConfigService().currentApp.value != null &&
        getOriginalMenuModel() != null &&
        IConfigService().userInfo.value != null;
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
    var newAppParam = oldAppParam.copyWith()..applyResponse(pApplicationParameters);

    //Notify listeners about changed parameters
    List<ApplicationParameterChangedListener> copy = _appParameterListener.toList(growable: false);

    for (String key in pApplicationParameters.parameters.keys) {
      for (int i = 0; i < copy.length; i++) {
          copy[i](key, oldAppParam.parameters[key], pApplicationParameters.parameters[key]);
      }
    }

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
  void setLayoutPosition(LayoutData layoutData) {
    // Copy list to avoid concurrent modification
    List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].compId == layoutData.id) {
        copy[i].layoutCallback?.call(layoutData);
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void registerAsLiveComponent(ComponentSubscription pComponentSubscription) {
    _componentSubscriptions.add(pComponentSubscription);
  }

  @override
  void registerModelSubscription(ModelSubscription pModelSubscription) {
    _modelSubscriptions.add(pModelSubscription);
  }

  @override
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pImmediatelyRetrieveData = true}) {
    _dataSubscriptions.removeWhere((element) => element.same(pDataSubscription));
    _dataSubscriptions.add(pDataSubscription);

    if (pImmediatelyRetrieveData) {
      DataBook? dataBook = IDataService().getDataBook(pDataSubscription.dataProvider);
      bool needsToFetch = IDataService().dataBookNeedsFetch(
        pFrom: pDataSubscription.from,
        pTo: pDataSubscription.to,
        pDataProvider: pDataSubscription.dataProvider,
      );
      bool fetchMetaData = dataBook?.metaData == null;

      //if we fetch metadata, it's not necessary to send GetMetaDataCommand again
      //if we don't fetch metadata, we have

      if (needsToFetch || fetchMetaData) {
        //metadata before data!
        if (!fetchMetaData && pDataSubscription.onMetaData != null) {
          //in this case, we have metadata and we should handle it

          ICommandService().sendCommand(GetMetaDataCommand(
            reason: "Subscription added",
            dataProvider: pDataSubscription.dataProvider,
            subId: pDataSubscription.id,
          ));
        }

        //this command triggers metadata update, if we fetch metadata
        ICommandService().sendCommand(FetchCommand(
          dataProvider: pDataSubscription.dataProvider,
          fromRow: dataBook?.records.keys.maxOrNull ?? pDataSubscription.from,
          rowCount: pDataSubscription.to != null
              ? pDataSubscription.to! - pDataSubscription.from
              : IUiService().getSubscriptionRowCount(pDataSubscription.dataProvider),
          reason: "Fetch for DataSubscription [${pDataSubscription.dataProvider}]",
          includeMetaData: fetchMetaData,
        ));
      } else {
        //metadata before data!
        if (pDataSubscription.onMetaData != null) {
          ICommandService().sendCommand(GetMetaDataCommand(
            reason: "Subscription added",
            dataProvider: pDataSubscription.dataProvider,
            subId: pDataSubscription.id,
          ));
        }

        if (pDataSubscription.from != -1 && pDataSubscription.onDataChunk != null) {
          ICommandService().sendCommand(GetDataChunkCommand(
            reason: "Subscription added",
            dataProvider: pDataSubscription.dataProvider,
            from: pDataSubscription.from,
            to: pDataSubscription.to,
            subId: pDataSubscription.id,
            dataColumns: pDataSubscription.dataColumns,
          ));
        }

        if (pDataSubscription.onSelectedRecord != null) {
          ICommandService().sendCommand(GetSelectedDataCommand(
            subId: pDataSubscription.id,
            reason: "Subscription added",
            dataProvider: pDataSubscription.dataProvider,
            columnNames: pDataSubscription.dataColumns,
          ));
        }
      }

      if (pDataSubscription.onPage != null) {
        dataBook?.pageRecords.keys.forEach((pageKey) {
          ICommandService().sendCommand(GetPageChunkCommand(
            reason: "Subscription added",
            dataProvider: pDataSubscription.dataProvider,
            from: pDataSubscription.from,
            to: pDataSubscription.to,
            subId: pDataSubscription.id,
            pageKey: pageKey,
          ));
        });
      }
    }
  }

  @override
  void notifySubscriptionsOfReload(String pDataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].onReload != null && copy[i].onDataChunk != null && copy[i].from >= 0) {
        copy[i].to = copy[i].onReload!.call();
      }
    }
  }

  @override
  void disposeSubscriptions(Object pSubscriber) {
    disposeDataSubscription(pSubscriber: pSubscriber);
    _disposeComponentSubscription(pSubscriber);
    _disposeModelSubscription(pSubscriber);
  }

  @override
  void disposeDataSubscription({required Object pSubscriber, String? pDataProvider}) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].subbedObj == pSubscriber && (pDataProvider == null || copy[i].dataProvider == pDataProvider)) {
        _dataSubscriptions.remove(copy[i]);
      }
    }
  }

  @override
  Future<List<BaseCommand>> collectAllEditorSaveCommands(String? pId, String pReason) async {
    // Copy list to avoid concurrent modification
    List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

    List<BaseCommand> saveCommands = [];

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].compId != pId && copy[i].saveCallback != null) {
        var command = await copy[i].saveCallback!.call(pReason);
        if (command != null) {
          saveCommands.add(command);
        }
      }
    }

    return saveCommands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyAffectedComponents(Set<String> affectedIds) {

    for (int i = 0; i < affectedIds.length; i++) {
      // Copy list to avoid concurrent modification
      List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

      String id = affectedIds.elementAt(i);

      for (int j = 0; j < copy.length; j++) {
        if (copy[j].compId == id && copy[j].affectedCallback != null) {
          copy[j].affectedCallback!.call();
        }
      }
    }
  }

  @override
  void notifyBeforeModelUpdate(String modelId, Set<String> changedProperties) {
    // Copy list to avoid concurrent modification
    List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].compId == modelId && copy[i].beforeModelUpdateCallback != null) {
        // Notify active component
        copy[i].beforeModelUpdateCallback!.call(changedProperties);
      }
    }
  }

  @override
  void notifyModelUpdated(List<String> updatedModels) {
    for (int i = 0; i < updatedModels.length; i++) {
      // Copy list to avoid concurrent modification
      List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

      for (int j = 0; j < copy.length; j++) {
        if (copy[j].compId == updatedModels[i] && copy[j].modelUpdatedCallback != null) {
          // Notify active component
          copy[j].modelUpdatedCallback!.call();
        }
      }
    }
  }

  @override
  void notifyModels() {
    List<FlComponentModel> models = IStorageService().getComponentModels();

    for (var sub in _modelSubscriptions) {
      var model = models.firstWhereOrNull((model) => sub.check.call(model));

      if (model != null) {
        sub.onNewModel.call(model);
      }
    }
  }

  @override
  void notifyDataChange({
    required String pDataProvider,
    bool pUpdatedCurrentPage = true,
    String? pUpdatedPage,
    bool pFromStart = false
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider) {
        // Check if selected data changed
        if (pUpdatedPage != null && copy[i].onPage != null) {
          ICommandService().sendCommand(GetPageChunkCommand(
            reason: "Notify data was called",
            dataProvider: pDataProvider,
            subId: copy[i].id,
            from: copy[i].from,
            to: copy[i].to,
            pageKey: pUpdatedPage,
          ));
        }

        if (pUpdatedCurrentPage) {
          if (copy[i].onSelectedRecord != null) {
            ICommandService().sendCommand(GetSelectedDataCommand(
              reason: "Notify data was called with pFrom -1",
              dataProvider: pDataProvider,
              subId: copy[i].id,
              columnNames: copy[i].dataColumns,
            ));
          }

          if (copy[i].from != -1 && copy[i].onDataChunk != null) {
            ICommandService().sendCommand(GetDataChunkCommand(
              reason: "Notify data was called",
              dataProvider: pDataProvider,
              subId: copy[i].id,
              from: copy[i].from,
              to: copy[i].to,
              dataColumns: copy[i].dataColumns,
              fromStart: pFromStart
            ));
          }
        }
      }
    }
  }

  @override
  void notifyDataToDisplayMapChanged(String pDataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].onDataToDisplayMapChanged != null) {
        copy[i].onDataToDisplayMapChanged?.call();
      }
    }
  }

  @override
  void notifySelectionChange(String pDataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].onSelectedRecord != null) {
        ICommandService().sendCommand(GetSelectedDataCommand(
          subId: copy[i].id,
          reason: "Notify data was called with pFrom -1",
          dataProvider: pDataProvider,
          columnNames: copy[i].dataColumns,
        ));
      }
    }
  }

  @override
  void notifyMetaDataChange(String pDataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].onMetaData != null) {
        // Check if selected data changed
        ICommandService().sendCommand(GetMetaDataCommand(
          subId: copy[i].id,
          reason: "Notify data was called with pFrom -1",
          dataProvider: pDataProvider,
        ));
      }
    }
  }

  @override
  void sendSubsSelectedData({
    required String pSubId,
    required String pDataProvider,
    DataRecord? pDataRow,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].id == pSubId && copy[i].onSelectedRecord != null) {
        copy[i].onSelectedRecord!.call(pDataRow);
      }
    }
  }

  @override
  void sendSubsDataChunk({
    required String pSubId,
    required DataChunk pDataChunk,
    required String pDataProvider,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].id == pSubId && copy[i].onDataChunk != null) {
        copy[i].onDataChunk!.call(pDataChunk);
      }
    }
  }

  @override
  void sendSubsPageChunk({
    required String pSubId,
    required String pDataProvider,
    required DataChunk pDataChunk,
    required String pPageKey,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].id == pSubId && copy[i].onPage != null) {
        copy[i].onPage?.call(pPageKey, pDataChunk);
      }
    }
  }

  @override
  void sendSubsMetaData({
    required String pSubId,
    required String pDataProvider,
    required DalMetaData pMetaData,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider && copy[i].id == pSubId && copy[i].onMetaData != null) {
        copy[i].onMetaData!(pMetaData);
      }
    }
  }

  @override
  int getSubscriptionRowCount(String pDataProvider) {
    int rowCount = 0;

    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == pDataProvider) {
        if (copy[i].to == null) {
          return -1;
        }

        rowCount = max(rowCount, copy[i].to!);
      }
    }

    return rowCount;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  CustomScreen? getCustomScreen(String key) {
    return appManager?.customScreens[key];
  }

  @override
  CustomComponent? getCustomComponent(String pComponentName) {
    Map<String, CustomComponent>? comps = appManager?.replaceComponents;

    if (comps != null) {
      return comps[pComponentName];
    }
    else {
      return null;
    }
  }

  @override
  bool usesNativeRouting(String pScreenLongName) {
    CustomScreen? customScreen = getCustomScreen(pScreenLongName);

    if (customScreen == null) {
      // No replacement -> send
      return false;
    }

    bool hasReplaced = _originalMenuModel?.containsMenuItemWithLongName(pScreenLongName) ?? false;

    if (hasReplaced) {
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Uncategorized method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<JVxDialog> getJVxDialogs() {
    return _activeDialogs.toList(growable: false);
  }

  @override
  void showJVxDialog(JVxDialog pDialog) {
    List<JVxDialog> copy = _activeDialogs.toList(growable: false);

    MessageDialog? msg;

    if (pDialog is MessageDialog) {
      for (int i = 0; i < copy.length && msg == null; i++) {
        if (copy[i] is MessageDialog && (copy[i] as MessageDialog).command.componentName == pDialog.command.componentName) {
          msg = copy[i] as MessageDialog;
        }
      }
    }

    //not found means that all "other" JVxDialogs will be shown more than once
    if (msg == null) {
      _activeDialogs.add(pDialog);
      JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();

      //feedback for the user
      if (pDialog is IError) {
        HapticFeedback.heavyImpact();

        //better not
        //SystemSound.play(SystemSoundType.click);
      }
    } else {
      //it would also be possible to replace the dialog in _activeDialogs
      //but in this special case, we always re-use the same widget
      msg.command.apply((pDialog as MessageDialog).command);
    }
  }

  @override
  void closeJVxDialog(JVxDialog pDialog) {
    pDialog.onClose();

    _activeDialogs.remove(pDialog);
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeJVxDialogs() {
    _activeDialogs.clear();
    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void closeMessageDialog(String componentName) {
    _activeDialogs.removeWhere((element) => element is MessageDialog && element.command.componentName == componentName);

    JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();
  }

  @override
  void showErrorDialog({
    String? title,
    String? message,
    required Object error,
    StackTrace? stackTrace
  }) {
    ICommandService().sendCommand(
      OpenErrorDialogCommand(
        title: title,
        message: FlutterUI.translate(IUiService.getErrorMessage(error)),
        error: error,
        isTimeout: false,
        stackTrace: stackTrace,
        reason: "UIService async error",
      ),
    );

    FlutterUI.sendFeedback(error, stackTrace, "UIService async error");
  }

  @override
  Future<bool> saveAllEditors({String? pId, required String pReason}) async {
    return ICommandService().sendCommands(
      await collectAllEditorSaveCommands(pId, pReason),
      showDialogOnError: false,
      abortOnFirstError: false,
    );
  }

  @override
  void setFocus(String pComponentId) {
    removeFocus();
    focusedComponentId = pComponentId;
  }

  @override
  FlComponentModel? getFocus() {
    if (focusedComponentId == null) {
      return null;
    }

    return IStorageService().getComponentModel(pComponentId: focusedComponentId!);
  }

  @override
  bool hasFocus(String pComponentId) {
    return focusedComponentId == pComponentId;
  }

  @override
  void removeFocus([String? pComponentId]) {
    if (pComponentId == null || hasFocus(pComponentId)) {
      focusedComponentId = null;
    }
  }

  @override
  String? getCurrentWorkScreenName() {
    return (FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState)
        .pathParameters[MainLocation.screenNameKey];
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
        barrierColor: JVxColors.LIGHTER_BLACK.withAlpha(Color.getAlphaFromOpacity(0.75)),
        topControl: Container(
          height: 20,
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 6,
            width: 40,
            decoration: BoxDecoration(color: Colors.white.withAlpha(Color.getAlphaFromOpacity(0.5)), borderRadius: BorderRadius.circular(6)),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(topLeft: kDefaultBarTopRadius, topRight: kDefaultBarTopRadius),
        ),
        enableDrag: true,
        //otherwise the full height will be used - independent of the ContentBottomSheet
        expand: panelModel.preferredSize != null ? false : true,
        bounce: false,
        settings: routeSettings,
        builder: (context) => ContentBottomSheet(
          model: panelModel,
        ),
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
      unawaited(
          ICommandService().sendCommand(CloseContentCommand(componentName: pContentName, reason: "I got closed")));
    }

    IStorageService().deleteScreen(screenName: pContentName);
    await ILayoutService().deleteScreen(pComponentId: panelModel.id);
  }

  @override
  void disposeContents() {
    _activeContents.clear();

    BuildContext? uicontext = FlutterUI.getCurrentContext();

    //also clean routes, otherwise the navigator of the cached route would be the old navigator and
    //this would throw an exception in Navigator
    if (uicontext != null) {
      List<Route<dynamic>>? routes = FlutterUI.maybeOf(uicontext)?.jvxRouteObserver.knownRoutes;

      if (routes?.isNotEmpty == true) {
        List<Route<dynamic>>? copy = routes?.toList(growable: false);

        if (copy != null) {
          NavigatorState nav = Navigator.of(uicontext);

          for (int i = 0; i < copy.length; i++) {
            if (copy[i].settings.name?.startsWith(Content.ROUTE_SETTINGS_PREFIX) == true
                // different navigator state -> remove
                || copy[i].navigator != nav) {
              routes!.remove(copy[i]);

              try {
                copy[i].navigator?.removeRoute(copy[i]);
              }
              catch (e) {
                //not relevant because of old navigator
                FlutterUI.logUI.e(e);
              }
            }
          }
        }
      }
    }
  }

  @override
  bool isContentVisible(String pContentName) {
    return _activeContents.contains(pContentName) &&
        FlutterUI.of(FlutterUI.getCurrentContext()!).jvxRouteObserver.knownRoutes.firstWhereOrNull(
                (element) => element.settings.name == (Content.ROUTE_SETTINGS_PREFIX + pContentName)) !=
            null;
  }

  /// Adds a listener which receives application parameter changes
  @override
  void addApplicationParameterChangedListener(ApplicationParameterChangedListener listener) {
    _appParameterListener.add(listener);
  }

  /// Removes a listener which receives application parameter changes
  @override
  void removeApplicationParameterChangedListener(ApplicationParameterChangedListener listener) {
    _appParameterListener.remove(listener);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Intern methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

    bool offlineMode = IConfigService().offline.value;

    if (!offlineMode && pMenuModel != null) {
      menuGroupModels.addAll(pMenuModel.copy().menuGroups);
    }

    if (appManager != null) {
      appManager!.customScreens.forEach((key, screen) {
        CustomMenuItem? customMenuItem = appManager!.customMenuItems[key];

        MenuItemModel? oldMenuItem;

        if (pMenuModel != null) {
          oldMenuItem = pMenuModel.getMenuItemByLongName(key) ?? pMenuModel.getMenuItemByNavigationName(key);
        }

        //existing item configured for online only but we're offline -> remove item
        //existing item configured for offline only but we're online -> remove item
        if ((oldMenuItem != null) &&
            ((screen.showOnline && !screen.showOffline && offlineMode) ||
             (screen.showOffline && !screen.showOnline && !offlineMode))) {
          menuGroupModels.forEach((menuGroup) => menuGroup.items.remove(oldMenuItem));
        }
        else {
          //if registered screen is a new screen -> it requires at least one builder to be added to the menu
          if (oldMenuItem == null && customMenuItem == null &&
              (screen.screenBuilder != null || screen.headerBuilder != null ||screen.footerBuilder != null)) {
            // We have no menu item, therefore, create one on best-effort basis.
            customMenuItem = CustomMenuItem(
              group: "Custom",
              label: screen.screenTitle ?? "Custom Screen",
              faIcon: FontAwesomeIcons.notdef,
            );
          }

          // Check if we should show the menu item in the current mode
          if (customMenuItem != null &&
              ((screen.showOnline && !offlineMode) ||
               (screen.showOffline && offlineMode))) {
            MenuItemModel newMenuItem = MenuItemModel(
              screenLongName: oldMenuItem?.screenLongName ?? key,
              className: oldMenuItem?.className,
              navigationName: oldMenuItem?.navigationName ?? screen.keyNavigationName,
              label: customMenuItem.label,
              alternativeLabel: customMenuItem.alternativeLabel ?? oldMenuItem?.alternativeLabel,
              imageBuilder: customMenuItem.imageBuilder,
              // Only override image if there is no image builder.
              image: customMenuItem.imageBuilder == null ? oldMenuItem?.image : null,
            );

            // Check group (exists or changed)
            MenuGroupModel? menuGroupModel = menuGroupModels.firstWhereOrNull((group) => group.name == customMenuItem!.group);

            if (menuGroupModel == null) {
              // Make new group if it didn't exist.
              menuGroupModel = MenuGroupModel(
                name: customMenuItem.group,
                items: [newMenuItem],
              );

              menuGroupModels.add(menuGroupModel);
            }
            else {
              menuGroupModel.items.add(newMenuItem);
            }

            if (oldMenuItem != null) {
              // Finally remove menu items that we replaced.
              menuGroupModels.forEach((group) => group.items.remove(oldMenuItem));
            }
          }
        }
      });

      //remove empty groups
      menuGroupModels.removeWhere((group) => group.items.isEmpty);
    }

    print("-> am Ende: count ${menuGroupModels.length}");


    MenuModel menuModel = MenuModel(menuGroups: menuGroupModels);

    appManager?.modifyMenuModel(menuModel);

    return menuModel;
  }


  void _disposeModelSubscription(Object pSubscriber) {
    List<ModelSubscription> copy = _modelSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].subbedObj == pSubscriber) {
        _modelSubscriptions.remove(copy[i]);
      }
    }
  }

  void _disposeComponentSubscription(Object pSubscriber) {
    List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].subbedObj == pSubscriber) {
        _componentSubscriptions.remove(copy[i]);
      }
    }
  }

}
