/*
 * Copyright 2021 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
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
import '../../../flutter_ui.dart';
import '../../../mask/error/ierror.dart';
import '../../../mask/error/message_dialog.dart';
import '../../../mask/frame/frame.dart';
import '../../../mask/jvx_dialog.dart';
import '../../../mask/jvx_overlay.dart';
import '../../../mask/work_screen/content.dart';
import '../../../model/command/api/close_content_command.dart';
import '../../../model/command/api/close_screen_command.dart';
import '../../../model/command/api/fetch_command.dart';
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
import '../../../util/haptic_util.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/widget_util.dart';
import '../../apps/app.dart';
import '../../apps/i_app_service.dart';
import '../../command/i_command_service.dart';
import '../../config/i_config_service.dart';
import '../../data/i_data_service.dart';
import '../../layout/i_layout_service.dart';
import '../../service.dart';
import '../../storage/i_storage_service.dart';
import '../i_ui_service.dart';
import '../protect_config.dart';

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

  final ValueNotifier<bool> _designMode = ValueNotifier(false);

  final ValueNotifier<List<ProtectConfig>?> _protection = ValueNotifier(null);

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
  MenuItemModel? getMenuItem(String screenName) {
    return getMenuModel()
        .menuGroups
        .expand((group) => group.items)
        .firstWhereOrNull((item) => item.matchesScreenName(screenName));
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
  void updateDesignModeElement(String? id) {
    _designModeElement.value = id;
  }

  @override
  ValueListenable<List<ProtectConfig>?> get protection {
    return _protection;
  }

  @override
  void updateProtection(List<ProtectConfig>? config) {
    _protection.value = config;
  }

  @override
  Future<dynamic> getInput(
    String title,
    String fieldTitle,
    bool confirm, {
      FaIconData? faicon,
      IconData? icon
    }
  ) async {
    return WidgetUtil.showInputDialog(title, fieldTitle, confirm, faicon: faicon, icon: icon);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Beaming history will be cleared when it should not be possible to go back,
  // as you should not be able to go back to the splash screen or back to menu when u logged out

  @override
  void routeToMenu({bool replaceRoute = false}) {
    var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    if (replaceRoute ||
        lastBeamState.pathPatternSegments.contains("settings") ||
        lastBeamState.pathPatternSegments.contains("login")) {
      FlutterUI.clearHistory();
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/home");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/home");
    }
  }

  @override
  void routeToWorkScreen({required String screenName, bool replaceRoute = false, bool secure = false}) {
    var lastBeamState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;

    // Don't route if we are already there (can create history duplicates when using query parameters; e.g. in deep links)
    if (lastBeamState.pathParameters[MainLocation.screenNameKey] == screenName) {
      return;
    }

    MenuItemModel? menuItemModel = getMenuItem(screenName);
    String resolvedScreenName = menuItemModel?.navigationName ?? screenName;

    // Clear the history of the screen we are going to so we don't jump back into the history.
    if (!kIsWeb) {
      FlutterUI.getBeamerDelegate().beamingHistory.whereType<MainLocation>().forEach((location) {
        location.history.removeWhere((element) {
          String path = element.routeInformation.uri.toString();

          return path.endsWith("/screens/$resolvedScreenName")
                 || path.contains("/screens/$resolvedScreenName?");});
      });
    }

    FlutterUI.logUI.i("Routing to work-screen: $screenName, resolved name: $resolvedScreenName");

    if (replaceRoute ||
        lastBeamState.pathPatternSegments.contains("settings") ||
        lastBeamState.pathPatternSegments.contains("login")) {
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/screens/$resolvedScreenName${secure ? "?secure" : ""}");
    } else {
      FlutterUI.getBeamerDelegate().beamToNamed("/screens/$resolvedScreenName${secure ? "?secure" : ""}");
    }
  }

  @override
  void routeToSettings({bool replaceRoute = false}) {
    if (replaceRoute) {
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
  void setAppManager(AppManager? appManager) {
    appManager = appManager;
  }

  @override
  Future<T?> openDialog<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    bool isDismissible = true
  }) {
    return showDialog(
      context: context ?? FlutterUI.getCurrentContext()!,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) =>
        PopScope(
          canPop: isDismissible,
          child: builder.call(context),
        ),
    );
  }

  @override
  Future<T?> openDialogFullScreen<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    bool isDismissible = true,
    Duration? transitionDuration
  }) {
    return showGeneralDialog(
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 200),
      context: FlutterUI.getCurrentContext()!,
      pageBuilder: (context, animation, secondaryAnimation) => PopScope(
        canPop: isDismissible,
        child: builder.call(context)
      )
    );
  }


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
  void setMenuModel(MenuModel? menuModel) {
    _originalMenuModel = menuModel;

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
  void updateClientId(String? clientId) {
    _clientId.value = clientId;
  }

  @override
  ValueNotifier<ApplicationMetaDataResponse?> get applicationMetaData => _applicationMetaData;

  @override
  void updateApplicationMetaData(ApplicationMetaDataResponse? applicationMetaData) {
    _applicationMetaData.value = applicationMetaData;

    //MARK: Set global timeout for biometric reAuth

    // If application parameters contain biometric-login max timeout -> change the default
    Duration? timeout;

    int? hours = applicationMetaData?.biometricLoginMaxTimeout;

    if (hours != null) {
      timeout = Duration(hours: hours);

      ProtectConfig.reAuthMaxTimeout = timeout;
    }

  }

  @override
  ValueNotifier<ApplicationSettingsResponse> get applicationSettings => _applicationSettings;

  @override
  void updateApplicationSettings(ApplicationSettingsResponse applicationSettings) {
    _applicationSettings.value = applicationSettings;
  }

  @override
  ValueNotifier<ApplicationParameters> get applicationParameters => _applicationParameters;

  @override
  void updateApplicationParameters(ApplicationParametersResponse applicationParameters) {
    var oldAppParam = _applicationParameters.value;
    var newAppParam = oldAppParam.copyWith()..applyResponse(applicationParameters);

    getAppManager()?.modifyApplicationParameters(newAppParam);

    //Notify listeners about changed parameters
    List<ApplicationParameterChangedListener> copy = _appParameterListener.toList(growable: false);

    for (String key in applicationParameters.parameters.keys) {
      for (int i = 0; i < copy.length; i++) {
        copy[i](key, oldAppParam.parameters[key], applicationParameters.parameters[key]);
      }
    }

    _applicationParameters.value = newAppParam;
  }

  @override
  ValueNotifier<LayoutMode> get layoutMode => _layoutMode;

  @override
  void updateLayoutMode(LayoutMode layoutMode) {
    _layoutMode.value = layoutMode;
  }

  @override
  ValueNotifier<bool> get mobileOnly => _mobileOnly;

  @override
  void updateMobileOnly(bool mobileOnly) {
    _mobileOnly.value = mobileOnly;
  }

  @override
  ValueNotifier<bool> get webOnly => _webOnly;

  @override
  void updateWebOnly(bool webOnly) {
    _webOnly.value = webOnly;
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
  void registerAsLiveComponent(ComponentSubscription componentSubscription) {
    _componentSubscriptions.add(componentSubscription);
  }

  @override
  void registerModelSubscription(ModelSubscription modelSubscription) {
    _modelSubscriptions.add(modelSubscription);
  }

  @override
  void registerDataSubscription({required DataSubscription dataSubscription, bool immediatelyRetrieveData = true}) {
    _dataSubscriptions.removeWhere((element) => element.same(dataSubscription));
    _dataSubscriptions.add(dataSubscription);

    if (immediatelyRetrieveData) {
      DataBook? dataBook = IDataService().getDataBook(dataSubscription.dataProvider);
      bool needsToFetch = IDataService().dataBookNeedsFetch(
        from: dataSubscription.from,
        to: dataSubscription.to,
        dataProvider: dataSubscription.dataProvider,
      );
      bool fetchMetaData = dataBook?.metaData == null;

      //if we fetch metadata, it's not necessary to send GetMetaDataCommand again
      //if we don't fetch metadata, we have

      if (needsToFetch || fetchMetaData) {
        //metadata before data!
        if (!fetchMetaData && dataSubscription.onMetaData != null) {
          //in this case, we have metadata and we should handle it

          ICommandService().sendCommand(GetMetaDataCommand(
            reason: "Subscription added",
            dataProvider: dataSubscription.dataProvider,
            subId: dataSubscription.id,
          ));
        }

        //this command triggers metadata update, if we fetch metadata
        ICommandService().sendCommand(FetchCommand(
          dataProvider: dataSubscription.dataProvider,
          fromRow: dataBook?.records.keys.maxOrNull ?? dataSubscription.from,
          rowCount: dataSubscription.to != null
              ? dataSubscription.to! - dataSubscription.from
              : IUiService().getSubscriptionRowCount(dataSubscription.dataProvider),
          reason: "Fetch for DataSubscription [${dataSubscription.dataProvider}]",
          includeMetaData: fetchMetaData,
        ));
      } else {
        //metadata before data!
        if (dataSubscription.onMetaData != null) {
          ICommandService().sendCommand(GetMetaDataCommand(
            reason: "Subscription added",
            dataProvider: dataSubscription.dataProvider,
            subId: dataSubscription.id,
          ));
        }

        if (dataSubscription.from != -1 && dataSubscription.onDataChunk != null) {
          ICommandService().sendCommand(GetDataChunkCommand(
            reason: "Subscription added",
            dataProvider: dataSubscription.dataProvider,
            from: dataSubscription.from,
            to: dataSubscription.to,
            subId: dataSubscription.id,
            dataColumns: dataSubscription.dataColumns,
          ));
        }

        if (dataSubscription.onSelectedRecord != null) {
          ICommandService().sendCommand(GetSelectedDataCommand(
            subId: dataSubscription.id,
            reason: "Subscription added",
            dataProvider: dataSubscription.dataProvider,
            columnNames: dataSubscription.dataColumns,
          ));
        }
      }

      if (dataSubscription.onPage != null) {
        dataBook?.pageRecords.keys.forEach((pageKey) {
          ICommandService().sendCommand(GetPageChunkCommand(
            reason: "Subscription added",
            dataProvider: dataSubscription.dataProvider,
            from: dataSubscription.from,
            to: dataSubscription.to,
            subId: dataSubscription.id,
            pageKey: pageKey,
          ));
        });
      }
    }
  }

  @override
  void notifySubscriptionsOfReload(String dataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].onReload != null && copy[i].onDataChunk != null && copy[i].from >= 0) {
        copy[i].to = copy[i].onReload!.call();
      }
    }
  }

  @override
  void disposeSubscriptions(Object subscriber) {
    disposeDataSubscription(subscriber: subscriber);
    _disposeComponentSubscription(subscriber);
    _disposeModelSubscription(subscriber);
  }

  @override
  void disposeDataSubscription({required Object subscriber, String? dataProvider}) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].subbedObj == subscriber && (dataProvider == null || copy[i].dataProvider == dataProvider)) {
        _dataSubscriptions.remove(copy[i]);
      }
    }
  }

  @override
  Future<List<BaseCommand>> collectAllEditorSaveCommands(String? id, String reason) async {
    // Copy list to avoid concurrent modification
    List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

    List<BaseCommand> saveCommands = [];

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].compId != id && copy[i].saveCallback != null) {
        var command = await copy[i].saveCallback!.call(reason);
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

      bool noSubscription = true;

      for (int j = 0; j < copy.length; j++) {
        if (copy[j].compId == updatedModels[i] && copy[j].modelUpdatedCallback != null) {
          // Notify active component
          copy[j].modelUpdatedCallback!.call();
          noSubscription = false;
        }
      }

      if (noSubscription) {
        FlutterUI.logUI.d("Model without subscription: ${updatedModels[i]}");
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
    required String dataProvider,
    bool updatedCurrentPage = true,
    String? updatedPage,
    bool fromStart = false
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider) {
        // Check if selected data changed
        if (updatedPage != null && copy[i].onPage != null) {
          ICommandService().sendCommand(GetPageChunkCommand(
            reason: "Notify data was called",
            dataProvider: dataProvider,
            subId: copy[i].id,
            from: copy[i].from,
            to: copy[i].to,
            pageKey: updatedPage,
          ));
        }

        if (updatedCurrentPage) {
          if (copy[i].onSelectedRecord != null) {
            ICommandService().sendCommand(GetSelectedDataCommand(
              reason: "Notify data was called with from -1",
              dataProvider: dataProvider,
              subId: copy[i].id,
              columnNames: copy[i].dataColumns,
            ));
          }

          if (copy[i].from != -1 && copy[i].onDataChunk != null) {
            ICommandService().sendCommand(GetDataChunkCommand(
              reason: "Notify data was called",
              dataProvider: dataProvider,
              subId: copy[i].id,
              from: copy[i].from,
              to: copy[i].to,
              dataColumns: copy[i].dataColumns,
              fromStart: fromStart
            ));
          }
        }
      }
    }
  }

  @override
  void notifyDataToDisplayMapChanged(String dataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].onDataToDisplayMapChanged != null) {
        copy[i].onDataToDisplayMapChanged?.call();
      }
    }
  }

  @override
  void notifySelectionChange(String dataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].onSelectedRecord != null) {
        ICommandService().sendCommand(GetSelectedDataCommand(
          subId: copy[i].id,
          reason: "Notify data was called with from -1",
          dataProvider: dataProvider,
          columnNames: copy[i].dataColumns,
        ));
      }
    }
  }

  @override
  void notifyMetaDataChange(String dataProvider) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].onMetaData != null) {
        // Check if selected data changed
        ICommandService().sendCommand(GetMetaDataCommand(
          subId: copy[i].id,
          reason: "Notify data was called with from -1",
          dataProvider: dataProvider,
        ));
      }
    }
  }

  @override
  void sendSubsSelectedData({
    required String subId,
    required String dataProvider,
    DataRecord? dataRow,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].id == subId && copy[i].onSelectedRecord != null) {
        copy[i].onSelectedRecord!.call(dataRow);
      }
    }
  }

  @override
  void sendSubsDataChunk({
    required String subId,
    required DataChunk dataChunk,
    required String dataProvider,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].id == subId && copy[i].onDataChunk != null) {
        copy[i].onDataChunk!.call(dataChunk);
      }
    }
  }

  @override
  void sendSubsPageChunk({
    required String subId,
    required String dataProvider,
    required DataChunk dataChunk,
    required String pageKey,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].id == subId && copy[i].onPage != null) {
        copy[i].onPage?.call(pageKey, dataChunk);
      }
    }
  }

  @override
  void sendSubsMetaData({
    required String subId,
    required String dataProvider,
    required DalMetaData metaData,
  }) {
    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider && copy[i].id == subId && copy[i].onMetaData != null) {
        copy[i].onMetaData!(metaData);
      }
    }
  }

  @override
  int getSubscriptionRowCount(String dataProvider) {
    int rowCount = 0;

    List<DataSubscription> copy = _dataSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].dataProvider == dataProvider) {
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
  CustomComponent? getCustomComponent(String componentName) {
    Map<String, CustomComponent>? comps = appManager?.replaceComponents;

    if (comps != null) {
      return comps[componentName];
    }
    else {
      return null;
    }
  }

  @override
  bool usesNativeRouting(String screenLongName) {
    CustomScreen? customScreen = getCustomScreen(screenLongName);

    if (customScreen == null) {
      // No replacement -> send
      return false;
    }

    bool hasReplaced = _originalMenuModel?.containsMenuItemWithLongName(screenLongName) ?? false;

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
  void showJVxDialog(JVxDialog dialog) {
    List<JVxDialog> copy = _activeDialogs.toList(growable: false);

    MessageDialog? msg;

    if (dialog is MessageDialog) {
      for (int i = 0; i < copy.length && msg == null; i++) {
        if (copy[i] is MessageDialog && (copy[i] as MessageDialog).command.componentName == dialog.command.componentName) {
          msg = copy[i] as MessageDialog;
        }
      }
    }

    //not found means that all "other" JVxDialogs will be shown more than once
    if (msg == null) {
      _activeDialogs.add(dialog);
      JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.refreshDialogs();

      //feedback for the user
      if (dialog is IError) {
        HapticUtil.error();

        //better not
        //SystemSound.play(SystemSoundType.click);
      }
    } else {
      //it would also be possible to replace the dialog in _activeDialogs
      //but in this special case, we always re-use the same widget
      msg.command.apply((dialog as MessageDialog).command);
    }
  }

  @override
  void closeJVxDialog(JVxDialog dialog) {
    dialog.onClose();

    _activeDialogs.remove(dialog);
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
  Future<CommandResult> saveAllEditors({String? id, required String reason}) async {
    return ICommandService().sendCommands(
      await collectAllEditorSaveCommands(id, reason),
      showDialogOnError: false,
      abortOnFirstError: false,
    );
  }

  @override
  void setFocus(String componentId) {
    removeFocus();
    focusedComponentId = componentId;
  }

  @override
  FlComponentModel? getFocus() {
    if (focusedComponentId == null) {
      return null;
    }

    return IStorageService().getComponentModel(componentId: focusedComponentId!);
  }

  @override
  bool hasFocus(String? componentId) {
    return componentId != null && focusedComponentId == componentId;
  }

  @override
  void removeFocus([String? componentId]) {
    if (componentId == null || hasFocus(componentId)) {
      focusedComponentId = null;
    }
  }

  @override
  String? getCurrentWorkScreenName() {
    return (FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState)
        .pathParameters[MainLocation.screenNameKey];
  }

  @override
  void openContent(String contentName) {
    if (_activeContents.contains(contentName)) {
      return;
    }

    FlComponentModel? panelModel = IStorageService().getComponentByName(componentName: contentName);

    if (panelModel == null || panelModel is! FlPanelModel) {
      FlutterUI.logUI.e("Tried to open a content which is not panel!", stackTrace: StackTrace.current);
      return;
    }

    RouteSettings routeSettings = RouteSettings(
      name: Content.ROUTE_SETTINGS_PREFIX + contentName,
    );

    _activeContents.add(contentName);

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
  Future<void> closeContent(String contentName, [bool sendClose = true]) async {
    if (!_activeContents.contains(contentName)) {
      return;
    }

    FlComponentModel? panelModel = IStorageService().getComponentByName(componentName: contentName);
    if (panelModel == null || panelModel is! FlPanelModel) {
      FlutterUI.logUI.e("Tried to close a content which is not panel!", stackTrace: StackTrace.current);
      return;
    }

    _activeContents.remove(contentName);

    BuildContext? uicontext = FlutterUI.getCurrentContext();

    Route? route = FlutterUI.maybeOf(uicontext!)
        ?.jvxRouteObserver
        .knownRoutes
        .firstWhereOrNull((element) => element.settings.name == (Content.ROUTE_SETTINGS_PREFIX + contentName));

    if (route != null) {
      if (route.isCurrent) {
        Navigator.pop(uicontext);
      } else {
        if (route.navigator == null) {
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
                }
              }
            }
          }
      }
        else {
          route.navigator?.removeRoute(route);
        }
      }
    }

    if (sendClose) {
      unawaited(
          ICommandService().sendCommand(CloseContentCommand(componentName: contentName, reason: "Content got closed")));
    }

    IStorageService().deleteScreen(screenName: contentName);
    await ILayoutService().deleteScreen(componentId: panelModel.id);
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
  Future<void> closeAllScreens([bool popPage = true]) async {
    closeJVxDialogs();
    disposeContents();

    MenuModel menu = IUiService().getMenuModel();

    List<CloseScreenCommand> closeCommands = [];
    FlPanelModel? screenModel;

    List<String> names = [];

    for (int i = 0; i < menu.items.length; i++) {
      screenModel = IStorageService().getComponentByNavigationName(menu.items[i].navigationName);

      if (screenModel != null) {

        names.add(menu.items[i].navigationName);

        closeCommands.add(CloseScreenCommand(
          componentName: screenModel.name,
          reason: "User requested closing all screens",
          popPage: popPage
        ));
      }
    }

    if (closeCommands.isNotEmpty) {
      await ICommandService().sendCommands(closeCommands);
    }

      for (String name in names) {
        FlutterUI
            .getBeamerDelegate()
            .beamingHistory
            .whereType<MainLocation>()
            .forEach((location) {
          location.history.removeWhere(
                (element) => element.routeInformation.uri.toString().endsWith(name),
          );
        });
      }

    FrameState? frame = Frame.maybeOf(FlutterUI.getCurrentContext());

    if (frame != null) {
      frame.rebuild();
    }
  }

  @override
  bool isContentVisible(String contentName) {
    return _activeContents.contains(contentName) &&
        FlutterUI.of(FlutterUI.getCurrentContext()!).jvxRouteObserver.knownRoutes.firstWhereOrNull(
                (element) => element.settings.name == (Content.ROUTE_SETTINGS_PREFIX + contentName)) !=
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
  MenuModel _updateMenuModel(MenuModel? menuModel) {
    List<MenuGroupModel> menuGroupModels = [];

    bool offlineMode = IConfigService().offline.value;

    if (!offlineMode && menuModel != null) {
      menuGroupModels.addAll(menuModel.copy().menuGroups);
    }

    if (appManager != null) {
      appManager!.customScreens.forEach((key, screen) {
        CustomMenuItem? customMenuItem = appManager!.customMenuItems[key];

        MenuItemModel? oldMenuItem;

        if (menuModel != null) {
          oldMenuItem = menuModel.getMenuItemByLongName(key) ?? menuModel.getMenuItemByNavigationName(key);
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
              group: FlutterUI.translate("Custom"),
              label: FlutterUI.translate(screen.screenTitle ?? "Custom Screen"),
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
              label: FlutterUI.translate(customMenuItem.label),
              alternativeLabel: customMenuItem.alternativeLabel != null ? FlutterUI.translate(customMenuItem.alternativeLabel) : oldMenuItem?.alternativeLabel,
              imageBuilder: customMenuItem.imageBuilder,
              // Only override image if there is no image builder.
              image: customMenuItem.imageBuilder == null ? oldMenuItem?.image : null,
            );

            // Check group (exists or changed)
            MenuGroupModel? menuGroupModel = menuGroupModels.firstWhereOrNull((group) => group.name == customMenuItem!.group);

            if (menuGroupModel == null) {
              // Make new group if it didn't exist.
              menuGroupModel = MenuGroupModel(
                name: FlutterUI.translate(customMenuItem.group),
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

    MenuModel menuModelNew = MenuModel(menuGroups: menuGroupModels);

    appManager?.modifyMenuModel(menuModelNew);

    return menuModelNew;
  }


  void _disposeModelSubscription(Object subscriber) {
    List<ModelSubscription> copy = _modelSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].subbedObj == subscriber) {
        _modelSubscriptions.remove(copy[i]);
      }
    }
  }

  void _disposeComponentSubscription(Object subscriber) {
    List<ComponentSubscription> copy = _componentSubscriptions.toList(growable: false);

    for (int i = 0; i < copy.length; i++) {
      if (copy[i].subbedObj == subscriber) {
        _componentSubscriptions.remove(copy[i]);
      }
    }
  }

}
