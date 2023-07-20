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

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../../config/app_config.dart';
import '../../../flutter_ui.dart';
import '../../../model/command/api/startup_command.dart';
import '../../../model/request/api_exit_request.dart';
import '../../api/i_api_service.dart';
import '../../api/shared/repository/offline_api_repository.dart';
import '../../api/shared/repository/online_api_repository.dart';
import '../../command/i_command_service.dart';
import '../../config/i_config_service.dart';
import '../../service.dart';
import '../../ui/i_ui_service.dart';
import '../app.dart';
import '../i_app_service.dart';

/// Manages and controls the individual apps.
class AppService implements IAppService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late ValueNotifier<Set<String>> _storedAppIds;

  final ValueNotifier<Future<void>?> _startupFuture = ValueNotifier(null);
  final ValueNotifier<Future<void>?> _exitFuture = ValueNotifier(null);

  bool? _startedManually;
  Uri? _returnUri;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppService.create();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FutureOr<void> clear(ClearReason reason) {
    if (reason == ClearReason.DEFAULT) {
      _startedManually = null;
      _returnUri = null;
    }
  }

  @override
  Future<void> loadConfig() async {
    _storedAppIds = ValueNotifier(await IConfigService().getConfigHandler().getAppKeys());
  }

  @override
  ValueNotifier<Future<void>?> get startupFuture => _startupFuture;

  @override
  ValueNotifier<Future<void>?> get exitFuture => _exitFuture;

  @override
  Uri? get returnUri => _returnUri;

  @override
  set returnUri(Uri? value) => _returnUri = value;

  @override
  bool? get startedManually => _startedManually;

  @override
  bool wasStartedManually() => _startedManually ?? false;

  @override
  ValueListenable<Set<String>> getStoredAppIds() {
    return _storedAppIds;
  }

  @override
  Future<void> refreshStoredAppIds() async {
    _storedAppIds.value = await IConfigService().getConfigHandler().getAppKeys();
  }

  @override
  Set<String> getAppIds() {
    List<String>? externalConfigs = IConfigService()
        .getAppConfig()
        ?.serverConfigs
        ?.where((e) => e.isValid)
        .map((e) => App.computeId(e.appName, e.baseUrl.toString(), predefined: true)!)
        .toList();
    return {
      ..._storedAppIds.value,
      ...?externalConfigs,
    };
  }

  @override
  void saveLocationAsReturnUri() {
    BeamState? targetState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState?;
    if (targetState != null && targetState.uri.path.startsWith("/screens/")) {
      returnUri ??= Uri(path: targetState.uri.path);
    }
  }

  @override
  bool showAppsButton() {
    return IConfigService().getAppConfig()!.customAppsAllowed! ||
        !IConfigService().getAppConfig()!.predefinedConfigsLocked! ||
        (IAppService().getAppIds().length > 1 && !IConfigService().getAppConfig()!.forceSingleAppMode!);
  }

  @override
  bool showSingleAppModeSwitch() {
    return IConfigService().getAppConfig()!.customAppsAllowed! && !IConfigService().getAppConfig()!.forceSingleAppMode!;
  }

  @override
  bool isSingleAppMode() {
    if (IConfigService().getAppConfig()!.forceSingleAppMode!) return true;
    if (!IConfigService().getAppConfig()!.customAppsAllowed!) return false;
    return IConfigService().singleAppMode.value;
  }

  @override
  Future<void> removeAllApps() async {
    await Future.forEach<App>(
      await App.getAppsByIDs(getAppIds()),
      (e) => e.delete(),
    );
    await IConfigService().updatePrivacyPolicy(null);
  }

  @override
  Future<void> removePreviousAppVersions(String appId, String currentVersion) async {
    await IConfigService()
        .getFileManager()
        .removePreviousAppVersions(appId, currentVersion)
        .catchError((e, stack) => FlutterUI.log.e("Failed to delete old app directories ($appId)", e, stack));
  }

  @override
  Future<void> removeObsoletePredefinedApps() async {
    for (String id in _storedAppIds.value) {
      App? app = await App.getApp(id, forceIfMissing: true);
      if (app!.predefined && App.getPredefinedConfig(app.id) == null) {
        FlutterUI.log.i("Removing data from an now obsolete predefined app: ${app.id}");
        return app.delete();
      }
    }
  }

  @override
  Future<void> startDefaultApp() {
    return App.getAppsByIDs(getAppIds()).then((apps) {
      AppConfig appConfig = IConfigService().getAppConfig()!;
      bool showAppOverviewWithoutDefault = appConfig.showAppOverviewWithoutDefault!;
      App? defaultApp = apps.firstWhereOrNull((e) {
        return e.isDefault &&
            (e.predefined || ((appConfig.customAppsAllowed ?? false) || (appConfig.forceSingleAppMode ?? false)));
      });
      if (defaultApp == null && apps.length == 1 && !showAppOverviewWithoutDefault) {
        defaultApp = apps.firstOrNull;
      }
      if (defaultApp?.isStartable ?? false) {
        startApp(appId: defaultApp!.id, autostart: true);
      }
    });
  }

  @override
  Future<void> startApp({String? appId, bool? autostart}) {
    _exitFuture.value = null;
    return _startupFuture.value = _startApp(appId: appId, autostart: autostart)
        .catchError(FlutterUI.createErrorHandler("Failed to send startup"));
  }

  Future<void> _startApp({String? appId, bool? autostart}) async {
    if (appId == null && IConfigService().currentApp.value == null) {
      FlutterUI.log.e("Called 'startApp' without an appId or a currentApp");
      await IUiService().routeToAppOverview();
      return;
    }

    await _stopApp(restart: appId == null);

    if (appId != null) {
      await IConfigService().updateCurrentApp(appId);
    }
    _startedManually = !(autostart ?? !wasStartedManually());

    await IApiService().getRepository().stop();
    var repository = IConfigService().offline.value ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    IApiService().setRepository(repository);

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

  @override
  Future<void> stopApp() {
    _startupFuture.value = null;
    return _exitFuture.value =
        _stopApp().catchError(FlutterUI.createErrorHandler("There was an error while exiting the app"));
  }

  Future<void> _stopApp({bool restart = false}) async {
    var repository = IApiService().getRepository();
    if (repository is OnlineApiRepository && IUiService().clientId.value != null) {
      // Send request directly to avoid blocking command service shutdown.
      unawaited(repository
          .sendRequestAndForget(ApiExitRequest())
          .catchError((e, stack) => FlutterUI.log.e("Exit request failed", e, stack)));
    }

    await FlutterUI.clearServices(restart ? ClearReason.RESTART : ClearReason.DEFAULT);
    FlutterUI.resetPageBucket();

    if (!restart) {
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
