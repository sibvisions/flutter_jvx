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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:universal_io/io.dart';

import '../../custom/app_manager.dart';
import '../../custom/custom_component.dart';
import '../../custom/custom_screen.dart';
import '../../mask/frame/frame.dart';
import '../../mask/jvx_dialog.dart';
import '../../model/command/base_command.dart';
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
import 'protect_config.dart';

typedef ApplicationParameterChangedListener = void Function(String name, dynamic oldValue, dynamic newValue);

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

  static String getErrorMessage(Object? error) {
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
    } else if (error != null) {
      const String messageStart = "Exception: ";

      String message = error.toString();
      if (message.startsWith(messageStart)) {
        return message.substring(messageStart.length);
      }
      return message;
    } else {
      return "Unknown error";
    }
  }

  MenuItemModel? getMenuItem(String screenName);

  I18n i18n();

  /// Whether or not the app is currently in design mode.
  ValueListenable<bool> get designMode;

  /// Updates the design mode.
  void updateDesignMode(bool designMode);

  /// The currently selected element in the design mode.
  ValueListenable<String?> get designModeElement;

  /// Updates the design mode element.
  void updateDesignModeElement(String? id);

  /// the protection handling
  ValueListenable<List<ProtectConfig>?> get protection;

  /// Updates the protection.
  void updateProtection(List<ProtectConfig>? config);

  /// Gets UI input
  Future<dynamic> getInput(String title, String fieldTitle, bool confirm, {FaIconData? faicon, IconData? icon});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Route to meu page
  /// [replaceRoute] - true if the route should replace the route in its history
  /// false if it should add to it
  void routeToMenu({bool replaceRoute = false});

  /// Route to work screen page
  void routeToWorkScreen({required String screenName, bool replaceRoute = false, bool secure = false});

  /// Route to settings page
  void routeToSettings({bool replaceRoute = false});

  Future<void> routeToAppOverview();

  bool canRouteToAppOverview();

  /// Gets the current custom manager
  AppManager? getAppManager();

  /// Sets the current custom manager
  void setAppManager(AppManager? appManager);

  /// Opens a [Dialog]
  Future<T?> openDialog<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    bool isDismissible = true
  });

  /// Opens a [Dialog]
  Future<T?> openDialogFullScreen<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    bool isDismissible = true,
    Duration? transitionDuration
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Meta data management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the original sever-sent menu.
  ///
  /// **Not recommended for building the menu!**
  /// Use [getMenuModel] instead.
  MenuModel? getOriginalMenuModel();

  /// Returns the current menu.
  MenuModel getMenuModel();

  /// Returns the value notifier for the menu model
  /// DO NOT USE THE VALUE DIRECTLY, call [getMenuModel] instead to get a correctly modified instance.
  ValueNotifier<MenuModel> getMenuNotifier();

  /// Set menu model to be used when opening the menu
  void setMenuModel(MenuModel? menuModel);

  /// Clears the menu model (this is not the same as setting menu model to null)
  void clearMenuModel();

  /// Whether the user is currently logged in.
  ///
  /// **This method can only approximate the current status, so use this with caution!**
  bool loggedIn();

  /// Returns the current clientId.
  ///
  /// `null` if none is present.
  ValueNotifier<String?> get clientId;

  void updateClientId(String? clientId);

  /// Returns the last known [ApplicationMetaDataResponse].
  ValueNotifier<ApplicationMetaDataResponse?> get applicationMetaData;

  void updateApplicationMetaData(ApplicationMetaDataResponse? applicationMetaData);

  /// Retrieves the last known [ApplicationSettingsResponse].
  ValueNotifier<ApplicationSettingsResponse> get applicationSettings;

  /// Sets the [ApplicationSettingsResponse].
  void updateApplicationSettings(ApplicationSettingsResponse applicationSettings);

  /// Retrieves the last known [ApplicationParameters].
  ValueNotifier<ApplicationParameters> get applicationParameters;

  /// Sets the [ApplicationParameters].
  void updateApplicationParameters(ApplicationParametersResponse applicationParameters);

  /// Returns the app's layout mode.
  ///
  /// See also:
  /// * [DeviceStatusResponse].
  ValueNotifier<LayoutMode> get layoutMode;

  /// Sets the layout mode.
  void updateLayoutMode(LayoutMode layoutMode);

  /// Returns if mobile-only mode is currently forced.
  ///
  /// See also:
  /// * [Frame.wrapWithFrame]
  ValueNotifier<bool> get mobileOnly;

  /// Sets the mobile-only mode.
  void updateMobileOnly(bool mobileOnly);

  /// Returns if web-only mode is currently forced.
  ///
  /// See also:
  /// * [Frame.wrapWithFrame]
  ValueNotifier<bool> get webOnly;

  /// Sets the web-only mode.
  void updateWebOnly(bool webOnly);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // LayoutData management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify component of new [LayoutData].
  void setLayoutPosition(LayoutData layoutData);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Register as an active component, callback will be called when model
  void registerAsLiveComponent(ComponentSubscription componentSubscription);

  void registerModelSubscription(ModelSubscription modelSubscription);

  /// Register to receive a subscriptions of data from a specific dataProvider
  void registerDataSubscription({required DataSubscription dataSubscription, bool immediatelyRetrieveData = true});

  /// Notifies all subscriptions of a reload.
  void notifySubscriptionsOfReload(String dataProvider);

  /// Removes all active subscriptions
  void disposeSubscriptions(Object subscriber);

  /// Removes [DataSubscription] from [IUiService]
  void disposeDataSubscription({required Object subscriber, String? dataProvider});

  /// Collects all commands to do to save all editors.
  Future<List<BaseCommand>> collectAllEditorSaveCommands(String? id, String reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify affected parents that their children changed, should only be used
  /// when parent model hasn't been changed as well.
  void notifyAffectedComponents(Set<String> affectedIds);

  /// Notify changed live component before the model has changed
  void notifyBeforeModelUpdate(String modelId, Set<String> changedProperties);

  /// Notify changed live components that their model has changed
  void notifyModelUpdated(List<String> updatedModels);

  void notifyModels();

  /// Notify all components belonging to [dataProvider] that their underlying
  /// data may have changed.
  void notifyDataChange({
    required String dataProvider,
    bool updatedCurrentPage = true,
    String? updatedPage,
    bool fromStart = false
  });

  /// Notify components belonging to [dataProvider] that the display map has been changed.
  void notifyDataToDisplayMapChanged(String dataProvider);

  /// Notify all components belonging to [dataProvider] that their underlying
  /// data selection has changed.
  void notifySelectionChange(String dataProvider);

  /// Notify all components belonging to [dataProvider] that the meta data has been changed.
  void notifyMetaDataChange(String dataProvider);

  /// Calls the callback of all subscribed [DataSubscription]s with the new selected record.
  /// Null if no record is selected or if the selected record is not fetched.
  void sendSubsSelectedData({
    required String subId,
    required String dataProvider,
    DataRecord? dataRow,
  });

  /// Calls the callback of all subscribed [DataSubscription]s with the changed data.
  void sendSubsDataChunk({
    required String subId,
    required String dataProvider,
    required DataChunk dataChunk,
  });

  /// Calls the callback of all subscribed [DataSubscription]s
  void sendSubsPageChunk({
    required String subId,
    required String dataProvider,
    required DataChunk dataChunk,
    required String pageKey,
  });

  /// Calls the callback of all subscribed [DataSubscription]s with the changed meta data.
  void sendSubsMetaData({
    required String subId,
    required String dataProvider,
    required DalMetaData metaData,
  });

  /// Returns the highest row which any component is subscribed to on this data provider
  int getSubscriptionRowCount(String dataProvider);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets replace-type screen by screenName
  CustomScreen? getCustomScreen(String key);

  /// Gets a custom component with given name (ignores screen)
  CustomComponent? getCustomComponent(String componentName);

  /// If this screen beams or sends an open work-screen command first.
  bool usesNativeRouting(String screenLongName);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Uncategorized method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  List<JVxDialog> getJVxDialogs();

  void showJVxDialog(JVxDialog dialog);

  void closeJVxDialog(JVxDialog dialog);

  void closeJVxDialogs();

  void closeMessageDialog(String componentName);

  void showErrorDialog({
    String? title,
    String? message,
    required Object error,
    StackTrace? stackTrace
  });

  Future<CommandResult> saveAllEditors({String? id, required String reason});

  void setFocus(String componentId);

  FlComponentModel? getFocus();

  bool hasFocus(String? componentId);

  void removeFocus([String? componentId]);

  /// Returns the current work screen name from the route url.
  ///
  /// This is usually the same as in [MenuItemModel.label].
  String? getCurrentWorkScreenName();

  void openContent(String contentName);

  Future<void> closeContent(String name, [bool sendClose = true]);

  void disposeContents();

  Future<void> closeAllScreens([bool popPage = true]);

  bool isContentVisible(String contentName);

  /// Adds a listener which receives application parameter changes
  void addApplicationParameterChangedListener(ApplicationParameterChangedListener listener);

  /// Removes a listener which receives application parameter changes
  void removeApplicationParameterChangedListener(ApplicationParameterChangedListener listener);

}
