/*
 * Copyright 2022 SIB Visions GmbH
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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import '../../custom/app_manager.dart';
import '../../custom/custom_component.dart';
import '../../custom/custom_screen.dart';
import '../../mask/frame/frame.dart';
import '../../mask/frame_dialog.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/function_command.dart';
import '../../model/component/component_subscription.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/model_subscription.dart';
import '../../model/config/application_parameters.dart';
import '../../model/config/translation/i18n.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/menu/menu_item_model.dart';
import '../../model/menu/menu_model.dart';
import '../../model/response/application_meta_data_response.dart';
import '../../model/response/application_parameters_response.dart';
import '../../model/response/application_settings_response.dart';
import '../../model/response/device_status_response.dart';
import '../command/i_command_service.dart';
import '../service.dart';

/// Defines the base construct of a [IUiService]
/// Used to manage all interactions to and from the ui.
abstract class IUiService implements Service {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the singleton instance.
  factory IUiService() => services<IUiService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static String getErrorMessage(Object error) {
    if (error is DioException) {
      if ([
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ].contains(error.type)) {
        return "Connection to remote server timed out";
      }
      return "Could not connect to remote server";
    } else if (error is SocketException) {
      if (error.message.contains("timed out")) {
        return "Connection to remote server timed out";
      }
      return "Could not connect to remote server";
    } else {
      const String messageStart = "Exception: ";

      String message = error.toString();
      if (message.startsWith(messageStart)) {
        return message.substring(messageStart.length);
      }
      return message;
    }
  }

  MenuItemModel? getMenuItem(String pScreenName);

  I18n i18n();

  /// Whether or not the app is currently in design mode.
  ValueListenable<bool> get designMode;

  /// Updates the design mode.
  void updateDesignMode(bool designMode);

  /// The currently selected element in the design mode.
  ValueListenable<String?> get designModeElement;

  /// Updates the design mode element.
  void updateDesignModeElement(String? pId);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [command] to [ICommandService].
  ///
  /// ## Do not use any future functions except await because errors are swallowed!
  /// Alternatively use [ICommandService.sendCommand] to get an unmodified future.
  Future<void> sendCommand(BaseCommand command);

  /// Can be used to handle an async error
  handleAsyncError(Object error, StackTrace stackTrace);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Route to meu page
  /// pReplaceRoute - true if the route should replace the route in its history
  /// false if it should add to it
  void routeToMenu({bool pReplaceRoute = false});

  /// Route to work screen page
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false});

  /// Route to settings page
  void routeToSettings({bool pReplaceRoute = false});

  Future<void> routeToAppOverview();

  /// Gets the current custom manager
  AppManager? getAppManager();

  /// Sets the current custom manager
  void setAppManager(AppManager? pAppManager);

  /// Opens a [Dialog]
  Future<T?> openDialog<T>({
    required WidgetBuilder pBuilder,
    BuildContext? context,
    bool pIsDismissible = true,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Meta data management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the current menu
  MenuModel getMenuModel();

  /// Returns the value notifier for the menu model
  /// DO NOT USE THE VALUE DIRECTLY, call [getMenuModel] instead to get a correctly modified instance.
  ValueNotifier<MenuModel> getMenuNotifier();

  /// Set menu model to be used when opening the menu
  void setMenuModel(MenuModel? pMenuModel);

  /// Returns the current clientId.
  ///
  /// `null` if none is present.
  ValueNotifier<String?> get clientId;

  void updateClientId(String? pClientId);

  /// Returns the last known [ApplicationMetaDataResponse].
  ValueNotifier<ApplicationMetaDataResponse?> get applicationMetaData;

  void updateApplicationMetaData(ApplicationMetaDataResponse? pApplicationMetaData);

  /// Retrieves the last known [ApplicationSettingsResponse].
  ValueNotifier<ApplicationSettingsResponse> get applicationSettings;

  /// Sets the [ApplicationSettingsResponse].
  void updateApplicationSettings(ApplicationSettingsResponse pApplicationSettings);

  /// Retrieves the last known [ApplicationParameters].
  ValueNotifier<ApplicationParameters> get applicationParameters;

  /// Sets the [ApplicationParameters].
  void updateApplicationParameters(ApplicationParametersResponse pApplicationParameters);

  /// Returns the app's layout mode.
  ///
  /// See also:
  /// * [DeviceStatusResponse].
  ValueNotifier<LayoutMode> get layoutMode;

  /// Sets the layout mode.
  void updateLayoutMode(LayoutMode pLayoutMode);

  /// Returns if mobile-only mode is currently forced.
  ///
  /// See also:
  /// * [Frame.wrapWithFrame]
  ValueNotifier<bool> get mobileOnly;

  /// Sets the mobile-only mode.
  void updateMobileOnly(bool pMobileOnly);

  /// Returns if web-only mode is currently forced.
  ///
  /// See also:
  /// * [Frame.wrapWithFrame]
  ValueNotifier<bool> get webOnly;

  /// Sets the web-only mode.
  void updateWebOnly(bool pWebOnly);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // LayoutData management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify component of new [LayoutData].
  void setLayoutPosition({required LayoutData layoutData});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Register as an active component, callback will be called when model
  void registerAsLiveComponent({required ComponentSubscription pComponentSubscription});

  void registerModelSubscription(ModelSubscription pModelSubscription);

  /// Register to receive a subscriptions of data from a specific dataProvider
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pImmediatlyRetrieveData = true});

  /// Notifies all subscriptions of a reload.
  void notifySubscriptionsOfReload({required String pDataprovider});

  /// Removes all active subscriptions
  void disposeSubscriptions({required Object pSubscriber});

  /// Removes [DataSubscription] from [IUiService]
  void disposeDataSubscription({required Object pSubscriber, String? pDataProvider});

  /// Collects all commands to do to save all editors.
  Future<List<BaseCommand>> collectAllEditorSaveCommands(String? pId);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify affected parents that their children changed, should only be used
  /// when parent model hasn't been changed as well.
  void notifyAffectedComponents({required Set<String> affectedIds});

  /// Notify changed live components that their model has changed, will give
  /// them their new model.
  void notifyChangedComponents({required List<String> updatedModels});

  void notifyModels();

  /// Notify all components belonging to [pDataProvider] that their underlying
  /// data may have changed.
  void notifyDataChange({
    required String pDataProvider,
    bool pUpdatedCurrentPage = true,
    String? pUpdatedPage,
  });

  /// Notify all components belonging to [pDataProvider] that their underlying
  /// data selection has changed.
  void notifySelectionChange({
    required String pDataProvider,
  });

  /// Notify all components belonging to [pDataProvider] that the meta data has been changed.
  void notifyMetaDataChange({
    required String pDataProvider,
  });

  /// Calls the callback of all subscribed [DataSubscription]s with the new selected record.
  /// Null if no record is selected or if the selected record is not fetched.
  void sendSubsSelectedData({
    required String pSubId,
    required String pDataProvider,
    required DataRecord? pDataRow,
  });

  /// Calls the callback of all subscribed [DataSubscription]s with the changed data.
  void sendSubsDataChunk({
    required String pSubId,
    required String pDataProvider,
    required DataChunk pDataChunk,
  });

  /// Calls the callback of all subscribed [DataSubscription]s with the changed meta data.
  void sendSubsMetaData({
    required String pSubId,
    required String pDataProvider,
    required DalMetaData pMetaData,
  });

  /// Calls the callback of all subscribed [DataSubscription]s
  void sendSubsPageChunk({
    required String pSubId,
    required String pDataProvider,
    required DataChunk pDataChunk,
    required String pPageKey,
  });

  /// Returns the highest row which any component is subscribed to on this data provider
  int getSubscriptionRowcount({required String pDataProvider});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If this screen beams or sends an open workscreen command first.
  bool usesNativeRouting(String pScreenLongName);

  /// Gets replace-type screen by screenName
  CustomScreen? getCustomScreen(String key);

  /// Gets a custom component with given name (ignores screen)
  CustomComponent? getCustomComponent({required String pComponentName});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Unsorted method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void closeMessageDialog({required String componentId});

  List<JVxDialog> getJVxDialogs();

  void showJVxDialog(JVxDialog pDialog);

  void closeJVxDialog(JVxDialog pDialog);

  void closeJVxDialogs();

  Future<void> saveAllEditors({String? pId, required String pReason, CommandCallback? pFunction});

  void setFocus(String pComponentId);

  bool hasFocus(String pComponentId);

  FlComponentModel? getFocus();

  void removeFocus([String? pComponentId]);

  /// Returns the current work screen name from the route url.
  ///
  /// This is usually the same as in [MenuItemModel.label].
  String? getCurrentWorkscreenName();

  void openContent(String name);

  void closeContent(String name, [bool pSendClose = true]);

  bool isContentVisible(String pContentName);

  void notifyDataToDisplayMapChanged({required String pDataProvider});
}
