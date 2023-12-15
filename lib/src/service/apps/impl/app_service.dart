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
import '../../../config/server_config.dart';
import '../../../flutter_ui.dart';
import '../../../model/command/api/startup_command.dart';
import '../../../model/request/api_exit_request.dart';
import '../../../model/response/menu_view_response.dart';
import '../../../routing/locations/main_location.dart';
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

  final ValueNotifier<Set<String>> _storedAppIds = ValueNotifier({});

  List<App> _apps = [];

  final ValueNotifier<Future<void>?> _startupFuture = ValueNotifier(null);
  final ValueNotifier<Future<void>?> _exitFuture = ValueNotifier(null);

  bool _startedManually = false;
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
      _startedManually = false;
      _returnUri = null;
    }
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
  bool wasStartedManually() => _startedManually;

  @override
  ValueListenable<Set<String>> getStoredAppIds() {
    return _storedAppIds;
  }

  @override
  Future<void> refreshStoredApps() async {
    _storedAppIds.value = await IConfigService().getConfigHandler().getAppKeys();
    _apps = (await Future.wait(getAppIds().map((id) => App.getApp(id)))).whereNotNull().toList();
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
  List<App> getApps() {
    return _apps;
  }

  @override
  void saveLocationAsReturnUri() {
    BeamState targetState = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    if (targetState.uri.path.startsWith("/screens/")) {
      returnUri ??= Uri(path: targetState.uri.path);
    }
  }

  @override
  Uri? getApplicableReturnUri(List<MenuEntryResponse> menuItems) {
    Uri? uri = IAppService().returnUri;
    if (uri == null) {
      BeamState state = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
      var returnString = state.queryParameters[MainLocation.returnUriKey];
      if (returnString != null) {
        uri = Uri.tryParse(returnString);
      }
    }

    if (uri != null &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == "screens" &&
        menuItems.any((e) => e.navigationName == uri!.pathSegments[1])) {
      return uri;
    }

    return null;
  }

  @override
  Future<void> removeAllApps() async {
    await Future.forEach<App>(
      IAppService().getApps(),
      (app) => app.delete(),
    );
    await IConfigService().updatePrivacyPolicy(null);
  }

  @override
  Future<void> removePreviousAppVersions(String appId, String currentVersion) async {
    await IConfigService().getFileManager().removePreviousAppVersions(appId, currentVersion).catchError(
        (e, stack) => FlutterUI.log.e("Failed to delete old app directories ($appId)", error: e, stackTrace: stack));
  }

  @override
  Future<void> removeObsoletePredefinedApps() async {
    for (String id in await IConfigService().getConfigHandler().getAppKeys()) {
      App? app = await App.getApp(id, forceIfMissing: true);
      if (app!.predefined && App.getPredefinedConfig(app.id) == null) {
        FlutterUI.log.i("Removing data from an now obsolete predefined app: ${app.id}");
        return app.delete();
      }
    }
  }

  @override
  App? getStartupApp() {
    AppConfig appConfig = IConfigService().getAppConfig()!;

    List<App> apps = _apps;

    if (!appConfig.customAppsAllowed!) {
      apps = apps.where((e) => e.predefined).toList();
    }

    App? defaultApp = _apps.firstWhereOrNull((e) => e.isDefault && e.isStartable);

    if (defaultApp != null) {
      return defaultApp;
      // If custom apps are allowed, we aren't really allowed to add another app, so just start the first possible app.
    } else if (appConfig.forceSingleAppMode! && !appConfig.customAppsAllowed!) {
      return apps.firstWhereOrNull((app) => app.isStartable);
    } else if (apps.length == 1 && apps.first.isStartable && !appConfig.showAppOverviewWithoutDefault!) {
      return apps.first;
    }

    return null;
  }

  @override
  Future<void> startCustomApp(ServerConfig customConfig, {bool force = false, bool autostart = true}) async {
    App customApp = await App.createAppFromConfig(customConfig);
    BeamState state = FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState;
    bool loggedOut = (state.uri.path.startsWith("/login") || !IUiService().loggedIn());

    // Only start app if it isn't already running or the user isn't logged in.
    if (force || IConfigService().currentApp.value != customApp.id || loggedOut) {
      await IAppService().startApp(appId: customApp.id, autostart: autostart);
    }
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

    if (autostart != null) {
      _startedManually = !autostart;
    }

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
      await ICommandService().sendCommand(
        StartupCommand(
          reason: "InitApp",
        ),
        throwFirstErrorCommand: true,
      );
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
          .catchError((e, stack) => FlutterUI.log.e("Exit request failed", error: e, stackTrace: stack)));
    }

    await FlutterUI.clearServices(restart ? ClearReason.RESTART : ClearReason.DEFAULT);

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
