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

import '../../flutter_ui.dart';
import '../../model/command/api/exit_command.dart';
import '../../model/command/api/startup_command.dart';
import '../api/i_api_service.dart';
import '../api/shared/repository/offline_api_repository.dart';
import '../api/shared/repository/online_api_repository.dart';
import '../command/i_command_service.dart';
import '../config/i_config_service.dart';
import '../service.dart';
import '../ui/i_ui_service.dart';
import 'app.dart';

class AppService {
  bool _startedManually = false;

  late ValueNotifier<Set<String>> _storedAppIds;

  /// Returns the singleton instance.
  factory AppService() => services<AppService>();

  AppService.create();

  /// Loads the initial config.
  Future<void> loadConfig() async {
    _storedAppIds = ValueNotifier(await IConfigService().getConfigHandler().getAppKeys());
  }

  bool get startedManually => _startedManually;

  ///
  ValueListenable<Set<String>> get storedAppIds => _storedAppIds;

  /// Refreshes the currently known app ids.
  Future<void> refreshStoredAppIds() async {
    _storedAppIds.value = await IConfigService().getConfigHandler().getAppKeys();
  }

  /// Returns a list of all known app IDs.
  ///
  /// Attention: This list doesn't provide any information about the validity
  /// of these apps, they don't have to be "start-able" (meaning there is a name and a base url).
  Set<String> getAppIds() {
    List<String>? externalConfigs = IConfigService()
        .getAppConfig()
        ?.serverConfigs
        ?.where((e) => e.isValid)
        .map((e) => App.computeId(e.appName, e.baseUrl.toString(), predefined: true)!)
        .toList();
    return {
      ...storedAppIds.value,
      ...?externalConfigs,
    };
  }

  bool showAppsButton() {
    return IConfigService().getAppConfig()!.customAppsAllowed! ||
        !IConfigService().getAppConfig()!.predefinedConfigsLocked! ||
        (AppService().getAppIds().length > 1 && !IConfigService().getAppConfig()!.forceSingleAppMode!);
  }

  bool showSingleAppModeSwitch() {
    return IConfigService().getAppConfig()!.customAppsAllowed! && !IConfigService().getAppConfig()!.forceSingleAppMode!;
  }

  bool isSingleAppMode() {
    if (IConfigService().getAppConfig()!.forceSingleAppMode!) return true;
    if (!IConfigService().getAppConfig()!.customAppsAllowed!) return false;
    return IConfigService().singleAppMode.value;
  }

  Future<void> removeAllApps() async {
    await Future.forEach<App>(
      await App.getAppsByIDs(getAppIds()),
      (e) => e.delete(),
    );
    await IConfigService().updatePrivacyPolicy(null);
  }

  /// Tries to clear as much leftover app data from previous versions as possible.
  ///
  /// [SharedPreferences] are deliberately left behind as these are not versioned.
  Future<void> removePreviousAppVersions(String appId, String currentVersion) async {
    await IConfigService()
        .getFileManager()
        .removePreviousAppVersions(appId, currentVersion)
        .catchError((e, stack) => FlutterUI.log.e("Failed to delete old app directories ($appId)", e, stack));
  }

  /// Removes obsolete predefined apps.
  ///
  /// Obsolete predefined apps are apps that were predefined in previous versions
  /// of this app and are now no longer present, therefore we can clear their data.
  Future<void> removeObsoletePredefinedApps() async {
    for (String id in storedAppIds.value) {
      App? app = await App.getApp(id, forceIfMissing: true);
      if (app!.predefined && App.getPredefinedConfig(app.id) == null) {
        FlutterUI.log.i("Removing data from an now obsolete predefined app: ${app.id}");
        return app.delete();
      }
    }
  }

  Future<void> startApp({String? appId, bool? autostart}) async {
    if (appId == null && IConfigService().currentApp.value == null) {
      FlutterUI.log.e("Called 'startApp' without an appId or a currentApp");
      await IUiService().routeToAppOverview();
      return;
    }

    await stopApp(false);

    if (appId != null) {
      await IConfigService().updateCurrentApp(appId);
    }
    _startedManually = !(autostart ?? !_startedManually);

    await IApiService().getRepository().stop();
    var repository = IConfigService().offline.value ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    IApiService().setRepository(repository);

    await IConfigService().updateLastApp(IConfigService().currentApp.value);

    if (IConfigService().getFileManager().isSatisfied()) {
      // Only try to load if FileManager is available
      await IConfigService().reloadSupportedLanguages();
      // Update language to application language, if applicable.
      await IUiService().i18n().setLanguage(IConfigService().getLanguage());
    }

    if (!IConfigService().offline.value) {
      // Send startup to server
      await ICommandService().sendCommand(StartupCommand(
        reason: "InitApp",
      ));
    } else {
      IUiService().routeToMenu(pReplaceRoute: true);
    }
  }

  /// Stops the currently running app.
  Future<void> stopApp([bool resetAppName = true]) async {
    if (!IConfigService().offline.value && IUiService().clientId.value != null) {
      unawaited(ICommandService()
          .sendCommand(ExitCommand(reason: "App has been stopped"))
          .catchError((e, stack) => FlutterUI.log.e("Exit request failed", e, stack)));
    }

    await FlutterUI.clearServices(true);

    if (resetAppName) {
      await IConfigService().updateCurrentApp(null);
      await IUiService().i18n().setLanguage(IConfigService().getLanguage());
    }

    // Switch back to "default" repository.
    if (IApiService().getRepository() is! OnlineApiRepository) {
      await IApiService().getRepository().stop();
      var repository = OnlineApiRepository();
      await repository.start();
      IApiService().setRepository(repository);
    }
  }
}
