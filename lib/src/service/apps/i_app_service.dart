/*
 * Copyright 2023 SIB Visions GmbH
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

import 'package:flutter/foundation.dart';

import '../../config/server_config.dart';
import '../../model/response/menu_view_response.dart';
import '../../routing/locations/main_location.dart';
import '../service.dart';
import 'app.dart';

/// Defines the base construct of an [IAppService].
/// Manages and controls the individual apps.
///
/// See also:
/// * [App]
abstract class IAppService implements Service {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the singleton instance.
  factory IAppService() => services<IAppService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ValueListenable<Future<void>?> get startupFuture;

  ValueListenable<Future<void>?> get exitFuture;

  /// The per-app saved return URI.
  ///
  /// Used for inner-app returns.
  /// For example, after server-side logouts and expired sessions.
  ///
  /// See also:
  /// * [saveLocationAsReturnUri]
  /// * [getApplicableReturnUri]
  Uri? get returnUri;

  set returnUri(Uri? value);

  /// Returns the temporary app title, if set
  String? temporaryTitle();

  /// Returns whether the app was started manually
  bool wasStartedManually();

  /// Returns a value notifier for the set of stored app IDs.
  ValueListenable<Set<String>> getStoredAppIds();

  /// Refreshes the currently stored app IDs.
  Future<void> refreshStoredApps();

  /// Returns all known app IDs.
  ///
  /// Could be stale, use [refreshStoredApps] to update.
  ///
  /// Attention: This list doesn't provide any information about the validity
  /// of these apps, they don't have to be "start-able" (meaning there is a name and a base url).
  Set<String> getAppIds();

  /// Returns all known apps.
  ///
  /// Could be stale, use [refreshStoredApps] to update.
  ///
  /// Attention: This list doesn't provide any information about the validity
  /// of these apps, they don't have to be "start-able" (meaning there is a name and a base url).
  List<App> getApps();

  /// Saves the current screen location as the return URI (if applicable).
  ///
  /// See also:
  /// * [getApplicableReturnUri]
  void saveLocationAsReturnUri();

  /// Returns the optional return URI in case it is a screen route and is available
  /// to the current user by checking the available menu items.
  ///
  /// The return URI is used to navigate back to the previous screen after the next start/login.
  ///
  /// Sources of return URI:
  /// * [IAppService.returnUri] from inner-app returning.
  /// * [MainLocation.returnUriKey] from deep-linking and web-reloads.
  ///
  /// See also:
  /// * [saveLocationAsReturnUri]
  Uri? getApplicableReturnUri(List<MenuEntryResponse> menuItems);

  /// Removes all apps and associated data.
  Future<void> removeAllApps();

  /// Tries to clear as much leftover app data from previous versions (other than [currentVersion] as possible.
  ///
  /// [SharedPreferences] are deliberately left behind as these are not versioned.
  Future<void> removePreviousAppVersions(String appId, String currentVersion);

  /// Removes obsolete predefined apps.
  ///
  /// Obsolete predefined apps are apps that were predefined in previous versions
  /// of this app and are now no longer present, therefore we can clear their data.
  Future<void> removeObsoletePredefinedApps();

  /// Returns the startup app.
  App? getStartupApp();

  /// Creates an [App] from [customConfig] and starts it, if it isn't already running.
  ///
  /// Used by DeepLinks and Notifications.
  Future<void> startCustomApp({ServerConfig? config, App? app, String? appTitle, bool force = false, bool autostart = true});

  /// Starts the app specified by [appId] and stops the currently running app, if applicable.
  ///
  /// If [appId] is null, the current app will be restarted.
  ///
  /// If [autostart] is true, the call is considered a non-user action.
  /// For example when starting a default app without any user interaction.
  ///
  /// See also:
  /// * [App.createApp]
  /// * [stopApp]
  Future<void> startApp({String? appId, String? appTitle, bool? autostart});

  /// Stops the currently running app and performs any necessary cleanup.
  Future<void> stopApp();

  /// Gets whether the [app] is the current app and a user is logged in
  bool isLoggedIn(App app);

  /// Gets whether the [app] is the current app
  bool isCurrentApp(App app);

  ///  Sets [parameter] as application parameter.
  Future<void> setParameter(Map<String, dynamic> parameter);

}
