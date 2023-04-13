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

import 'package:collection/collection.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/exit_command.dart';
import '../../model/command/api/startup_command.dart';
import '../api/i_api_service.dart';
import '../api/shared/repository/offline_api_repository.dart';
import '../api/shared/repository/online_api_repository.dart';
import '../command/i_command_service.dart';
import '../config/config_controller.dart';
import '../service.dart';
import '../ui/i_ui_service.dart';
import 'app.dart';

class AppService {
  bool _startedManually = false;

  /// Returns the singleton instance.
  factory AppService() => services<AppService>();

  AppService.create();

  bool get startedManually => _startedManually;

  /// Returns a list of all known app IDs.
  ///
  /// Attention: This list doesn't provide any information about the validity
  /// of these apps, they don't have to be "start-able" (meaning there is a name and a base url).
  Set<String> getAppIds() {
    List<String>? externalConfigs = ConfigController()
        .getAppConfig()
        ?.serverConfigs
        ?.where((e) => e.isValid)
        .map((e) => App.computeId(e.appName, e.baseUrl.toString(), predefined: true)!)
        .toList();
    return {
      ...getStoredAppIds(),
      ...?externalConfigs,
    };
  }

  Set<String> getStoredAppIds() {
    RegExp regExp = RegExp(r'(.+)\..+');
    return ConfigController()
        .getConfigService()
        .getSharedPreferences()
        .getKeys()
        .map((element) => regExp.allMatches(element))
        .where((e) => e.isNotEmpty)
        .map((e) => e.first[1].toString())
        .sorted((a, b) => b.compareTo(a))
        .toSet();
  }

  bool showAppsButton() {
    return ConfigController().getAppConfig()!.customAppsAllowed! ||
        !ConfigController().getAppConfig()!.predefinedConfigsLocked! ||
        (AppService().getAppIds().length > 1 && !ConfigController().getAppConfig()!.forceSingleAppMode!);
  }

  bool isSingleAppMode() {
    if (ConfigController().getAppConfig()!.forceSingleAppMode!) return true;
    if (!ConfigController().getAppConfig()!.customAppsAllowed!) return false;
    return ConfigController().singleAppMode.value;
  }

  Future<void> removeAllApps() async {
    await Future.forEach<App>(
      App.getAppsByIDs(getAppIds()).where((app) => !app.locked),
      (e) => e.delete(),
    );
    await ConfigController().updatePrivacyPolicy(null);
  }

  /// Tries to clear as much leftover app data from previous versions as possible.
  ///
  /// [SharedPreferences] are deliberately left behind as these are not versioned.
  Future<void> removePreviousAppVersions(String appId, String currentVersion) async {
    await ConfigController()
        .getFileManager()
        .removePreviousAppVersions(appId, currentVersion)
        .catchError((e, stack) => FlutterUI.log.e("Failed to delete old app directories ($appId)", e, stack));
  }

  /// Removes obsolete predefined apps.
  ///
  /// Obsolete predefined apps are apps that were predefined in previous versions
  /// of this app and are now no longer present, therefore we can clear their data.
  Future<void> removeObsoletePredefinedApps() async {
    await Future.forEach<App>(
      getStoredAppIds()
          .map((id) => App.getApp(id, forceIfMissing: true)!)
          .where((app) => app.predefined && App.getPredefinedConfig(app.id) == null),
      (e) {
        FlutterUI.log.i("Removing data from an now obsolete predefined app: ${e.id}");
        return e.delete(forced: true);
      },
    );
  }

  Future<void> startApp({String? appId, bool? autostart}) async {
    if (appId == null && ConfigController().currentApp.value == null) {
      FlutterUI.log.e("Called 'startApp' without an appId or a currentApp");
      await IUiService().routeToAppOverview();
      return;
    }

    await stopApp(false);

    if (appId != null) {
      await ConfigController().updateCurrentApp(appId);
    }
    _startedManually = !(autostart ?? !_startedManually);

    await IApiService().getRepository().stop();
    var repository = ConfigController().offline.value ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    IApiService().setRepository(repository);

    await ConfigController().updateLastApp(ConfigController().currentApp.value);

    if (ConfigController().getFileManager().isSatisfied()) {
      // Only try to load if FileManager is available
      ConfigController().reloadSupportedLanguages();
      ConfigController().loadLanguages();
    }

    if (ConfigController().offline.value) {
      IUiService().routeToMenu(pReplaceRoute: true);
      return;
    }

    // Send startup to server
    await ICommandService().sendCommand(StartupCommand(
      reason: "InitApp",
    ));
  }

  /// Stops the currently running app.
  Future<void> stopApp([bool resetAppName = true]) async {
    if (!ConfigController().offline.value && IUiService().clientId.value != null) {
      unawaited(ICommandService()
          .sendCommand(ExitCommand(reason: "App has been stopped"))
          .catchError((e, stack) => FlutterUI.log.e("Exit request failed", e, stack)));
    }

    await FlutterUI.clearServices(true);
    if (resetAppName) {
      await ConfigController().updateCurrentApp(null);
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
