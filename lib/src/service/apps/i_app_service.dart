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

  /// Loads the initial configuration.
  Future<void> loadConfig();

  ValueListenable<Future<void>?> get startupFuture;
  ValueListenable<Future<void>?> get exitFuture;

  /// The saved return URI.
  ///
  /// Represents the last screen location to which we should return to after the next start/login.
  Uri? get returnUri;

  set returnUri(Uri? value);

  /// Indicates whether the app was started manually.
  bool? get startedManually;

  /// Returns whether the app was started manually, returns `false` if unset.
  bool wasStartedManually();

  /// Returns a value notifier for the set of stored app IDs.
  ValueListenable<Set<String>> getStoredAppIds();

  /// Refreshes the currently stored app IDs.
  Future<void> refreshStoredAppIds();

  /// Returns all known app IDs.
  ///
  /// Could be stale, use [refreshStoredAppIds] to update.
  ///
  /// Attention: This list doesn't provide any information about the validity
  /// of these apps, they don't have to be "start-able" (meaning there is a name and a base url).
  Set<String> getAppIds();

  /// Saves the current screen location as the return URI (if applicable).
  ///
  /// The return URI is used to navigate back to the previous screen after the next start/login.
  /// For example when the server logs us out or sends a session expired.
  void saveLocationAsReturnUri();

  /// Determines whether the "Apps" button should be shown.
  bool showAppsButton();

  /// Determines whether the single app mode switch should be shown.
  bool showSingleAppModeSwitch();

  /// Checks if the app is in single app mode.
  bool isSingleAppMode();

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

  /// Retrieves all known apps and starts a default app, if applicable.
  Future<void> startDefaultApp();

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
  Future<void> startApp({String? appId, bool? autostart});

  /// Stops the currently running app and performs any necessary cleanup.
  Future<void> stopApp();
}
