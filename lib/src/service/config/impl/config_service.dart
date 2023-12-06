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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:universal_io/io.dart' as universal_io;

import '../../../config/app_config.dart';
import '../../../config/predefined_server_config.dart';
import '../../../flutter_ui.dart';
import '../../../mask/frame/frame.dart';
import '../../../model/config/translation/i18n.dart';
import '../../../model/config/user/user_info.dart';
import '../../apps/app.dart';
import '../../apps/i_app_service.dart';
import '../../file/file_manager.dart';
import '../../service.dart';
import '../../ui/i_ui_service.dart';
import '../i_config_service.dart';
import '../shared/config_handler.dart';
import '../shared/handler/shared_prefs_handler.dart';

class ConfigService implements IConfigService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final ConfigHandler _configHandler;

  /// Used to manage files, different implementations for web and mobile.
  final IFileManager _fileManager;

  /// Map of all active callbacks.
  final Map<String, List<Function>> _callbacks = {};

  Map<String, dynamic> _customStartupProperties = {};

  AppConfig? _appConfig;

  late ValueNotifier<ThemeMode> _themePreference;

  late ValueNotifier<bool> _singleAppMode;

  late ValueNotifier<String?> _defaultApp;

  late ValueNotifier<String?> _lastApp;

  late ValueNotifier<Uri?> _privacyPolicy;

  late ValueNotifier<String?> _appId;

  late ValueNotifier<String?> _appName;

  late ValueNotifier<Uri?> _baseUrl;

  late ValueNotifier<String?> _username;

  late ValueNotifier<String?> _password;

  late ValueNotifier<String?> _title;

  late ValueNotifier<String?> _icon;

  late ValueNotifier<bool?> _locked;

  late ValueNotifier<bool?> _parametersHidden;

  late ValueNotifier<String?> _version;

  late ValueNotifier<String?> _authKey;

  /// UserInfo about the current user.
  late ValueNotifier<UserInfo?> _userInfo;

  /// The current offline state.
  late ValueNotifier<bool> _offline;

  late ValueNotifier<String?> _offlineScreen;

  /// Application style sent from server.
  late ValueNotifier<Map<String, String>?> _applicationStyle;

  late ValueNotifier<bool?> _customLanguage;

  late ValueNotifier<String?> _userLanguage;

  late ValueNotifier<String?> _applicationLanguage;

  late ValueNotifier<String?> _applicationTimeZone;

  late ValueNotifier<int?> _pictureResolution;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Non-persistent fields (fields that don't use a backend service)
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? _platformTimeZone;

  final ValueNotifier<Set<String>> _supportedLanguages = ValueNotifier({});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService.create({
    required IFileManager fileManager,
    required ConfigHandler configHandler,
  })  : _configHandler = configHandler,
        _fileManager = fileManager;

  @override
  Future<void> loadConfig(AppConfig pAppConfig, [bool devConfig = false]) async {
    _appConfig = pAppConfig;
    await _migrateConfig();

    _themePreference = ValueNotifier(await _configHandler.themePreference() ?? ThemeMode.system);
    _pictureResolution = ValueNotifier(await _configHandler.pictureResolution());
    _singleAppMode = ValueNotifier(await _configHandler.singleAppMode());
    _defaultApp = ValueNotifier(await _configHandler.defaultApp());
    _lastApp = ValueNotifier(await _configHandler.lastApp());
    var privacyPolicy = await _configHandler.privacyPolicy();
    _privacyPolicy =
        ValueNotifier((privacyPolicy != null ? Uri.parse(privacyPolicy) : null) ?? _appConfig?.privacyPolicy);

    if (_appConfig?.serverConfigs != null) {
      // DevConfig resets persistent fields to enable config-fallback logic.
      if (devConfig) {
        // Remove every saved config from provided dev configs.
        await Future.forEach<String>(
          _appConfig!.serverConfigs!
              .map((e) => App.computeId(e.appName, e.baseUrl.toString(), predefined: true))
              .whereNotNull(),
          (e) => App.getApp(e).then((app) => app?.delete()),
        );
      }
    }

    _appId = ValueNotifier(null);
    _appName = ValueNotifier(null);
    _baseUrl = ValueNotifier(null);
    _username = ValueNotifier(null);
    _password = ValueNotifier(null);
    _title = ValueNotifier(null);
    _icon = ValueNotifier(null);
    _locked = ValueNotifier(null);
    _parametersHidden = ValueNotifier(null);
    _version = ValueNotifier(null);
    _authKey = ValueNotifier(null);
    _userInfo = ValueNotifier(null);
    _offline = ValueNotifier(false);
    _offlineScreen = ValueNotifier(null);
    _customLanguage = ValueNotifier(null);
    _userLanguage = ValueNotifier(null);
    _applicationStyle = ValueNotifier(null);
    _applicationLanguage = ValueNotifier(null);
    _applicationTimeZone = ValueNotifier(null);

    // Update native timezone
    _platformTimeZone = await FlutterTimezone.getLocalTimezone();
  }

  @override
  Future<void> refreshDefaultApp([bool pOverride = false]) async {
    App? app;

    if (!pOverride && defaultApp.value != null) {
      app = await App.getApp(defaultApp.value!);

      if (app?.predefined == false && !_appConfig!.customAppsAllowed!) {
        app = null;
      }
    }

    if (app == null) {
      var predefinedDefault = _appConfig!.serverConfigs?.firstWhereOrNull((element) => element.isDefault ?? false);
      await updateDefaultApp(
        App.computeId(predefinedDefault?.appName, predefinedDefault?.baseUrl?.toString(), predefined: true),
      );
    }
  }

  Future<void> _updateAppSpecificValues() async {
    final String? appId = _appId.value;

    App? app = appId != null ? await App.getApp(appId) : null;
    bool useUserSettings = app?.usesUserParameter ?? true;
    PredefinedServerConfig? predefinedApp = App.getPredefinedConfig(appId);

    _appName.value = (useUserSettings ? await _configHandler.appName() : null) ?? predefinedApp?.appName;
    String? baseUrl = await _configHandler.baseUrl();
    _baseUrl.value = (useUserSettings ? (baseUrl != null ? Uri.parse(baseUrl) : null) : null) ?? predefinedApp?.baseUrl;
    _username.value = await _configHandler.username() ?? predefinedApp?.username;
    _password.value = await _configHandler.password() ?? predefinedApp?.password;
    _title.value = (useUserSettings ? await _configHandler.title() : null) ?? predefinedApp?.title;
    _icon.value = await _configHandler.icon() ?? predefinedApp?.icon;
    _locked.value = app?.locked;
    _parametersHidden.value = app?.parametersHidden;
    _version.value = await _configHandler.version();
    _authKey.value = await _configHandler.authKey();
    _userInfo.value = await _configHandler.userInfo();
    _offline.value = await _configHandler.offline();
    _offlineScreen.value = await _configHandler.offlineScreen();
    _customLanguage.value = await _configHandler.customLanguage();
    _userLanguage.value = await _configHandler.userLanguage();
    _applicationStyle.value = await _configHandler.applicationStyle();
    _applicationLanguage.value = await _configHandler.applicationLanguage();
    _applicationTimeZone.value = await _configHandler.applicationTimeZone();
  }

  /// Migrates old config
  Future<void> _migrateConfig() async {
    var configHandler = getConfigHandler();

    if (configHandler is SharedPrefsHandler) {
      // TODO remove in future versions
      var sharedPrefs = configHandler.getSharedPreferences();

      Future<void> migrateApp(String id) async {
        await sharedPrefs.setString("$id.name", id);
        String newAppId =
            App.computeId(sharedPrefs.getString("$id.name"), sharedPrefs.getString("$id.baseUrl"), predefined: false)!;

        await Future.wait(
          sharedPrefs.getKeys().where((e) => e.startsWith("$id.")).map((e) async {
            var value = sharedPrefs.get(e);
            await sharedPrefs.remove(e);
            assert(value != null);

            String subKey = e.substring(e.indexOf(".")); // e.g. ".baseUrl"
            String newKey = newAppId + subKey;

            if (value is String) {
              await sharedPrefs.setString(newKey, value);
            } else if (value is bool) {
              await sharedPrefs.setBool(newKey, value);
            } else if (value is int) {
              await sharedPrefs.setInt(newKey, value);
            } else if (value is double) {
              await sharedPrefs.setDouble(newKey, value);
            } else if (value is List<String>) {
              await sharedPrefs.setStringList(newKey, value);
            } else {
              assert(false, "${value.runtimeType} is not supported by SharedPreferences");
            }
          }).toList(),
        );

        String? sCurrentApp = await configHandler.currentApp();
        if (sCurrentApp == id) {
          await configHandler.updateCurrentApp(newAppId);
        }
        String? sLastApp = await configHandler.lastApp();
        if (sLastApp == id) {
          await configHandler.updateLastApp(newAppId);
        }
        String? sDefaultApp = await configHandler.defaultApp();
        if (sDefaultApp == id) {
          await configHandler.updateDefaultApp(newAppId);
        }

        try {
          await getFileManager().renameIndependentDirectory([id], newAppId);
        } catch (e, stack) {
          FlutterUI.log.w("Failed to migrate app directory ($id)", error: e, stackTrace: stack);
        }
      }

      Future<void> removeApp(String id) async {
        await Future.wait(
          sharedPrefs.getKeys().where((e) => e.startsWith("$id.")).map((e) => sharedPrefs.remove(e)).toList(),
        ).then((_) async {
          String? sCurrentApp = await configHandler.currentApp();
          if (sCurrentApp == id) {
            await configHandler.updateCurrentApp(null);
          }
          String? sLastApp = await configHandler.lastApp();
          if (sLastApp == id) {
            await configHandler.updateLastApp(null);
          }
          String? sDefaultApp = await configHandler.defaultApp();
          if (sDefaultApp == id) {
            await configHandler.updateDefaultApp(null);
          }

          try {
            await getFileManager().deleteIndependentDirectory([id], recursive: true);
          } catch (e, stack) {
            FlutterUI.log.w("Failed to delete old app directory ($id)", error: e, stackTrace: stack);
          }
        });
      }

      var iterable = IAppService().getStoredAppIds().value.where((id) =>
          !id.contains(App.idSplitSequence) &&
          !id.startsWith(App.predefinedPrefix) &&
          !sharedPrefs.containsKey("$id.name"));
      for (var id in iterable) {
        try {
          String? baseUrl = sharedPrefs.getString("$id.baseUrl");
          if (baseUrl != null) {
            if (!_appConfig!.serverConfigs!.any((e) => e.appName == id && e.baseUrl.toString() == baseUrl)) {
              // Is valid and custom, migrate it.
              FlutterUI.log.i("Migrating old app ($id)");
              await migrateApp(id);
            } else {
              // Is equals to a predefined app, delete it.
              FlutterUI.log.i("Removing old-predefined app ($id)");
              await removeApp(id);
            }
          } else {
            // Doesn't contain properties to start, delete it.
            FlutterUI.log.i("Removing old app ($id)");
            await removeApp(id);
          }
        } catch (e, stack) {
          FlutterUI.log.e("Failed to migrate app ($id)", error: e, stackTrace: stack);
        }
      }

      await sharedPrefs.remove("appName");
    }
  }

  @override
  FutureOr<void> clear(ClearReason reason) {}

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Helper-methods for non-persistent fields
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ConfigHandler getConfigHandler() {
    return _configHandler;
  }

  @override
  IFileManager getFileManager() {
    return _fileManager;
  }

  @override
  String getPlatformLocale() {
    int? end = universal_io.Platform.localeName.indexOf(RegExp("[_-]"));
    return universal_io.Platform.localeName.substring(0, end == -1 ? null : end);
  }

  @override
  String? getPlatformTimeZone() {
    return _platformTimeZone;
  }

  @override
  AppConfig? getAppConfig() {
    return _appConfig;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Persisting methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ValueListenable<ThemeMode> get themePreference => _themePreference;

  @override
  Future<void> updateThemePreference(ThemeMode themeMode) async {
    await _configHandler.updateThemePreference(themeMode == ThemeMode.system ? null : themeMode);
    _themePreference.value = themeMode;
  }

  @override
  ValueListenable<int?> get pictureResolution => _pictureResolution;

  @override
  Future<void> updatePictureResolution(int pictureResolution) async {
    await _configHandler.updatePictureResolution(pictureResolution);
    _pictureResolution.value = pictureResolution;
  }

  @override
  ValueListenable<bool> get singleAppMode => _singleAppMode;

  @override
  Future<void> updateSingleAppMode(bool? singleAppMode) async {
    await _configHandler.updateSingleAppMode(singleAppMode);
    _singleAppMode.value = singleAppMode ?? await _configHandler.singleAppMode();
  }

  @override
  ValueListenable<String?> get defaultApp => _defaultApp;

  @override
  Future<void> updateDefaultApp(String? appId) async {
    if (appId != defaultApp.value) {
      await _configHandler.updateDefaultApp(appId);
      _defaultApp.value = appId;
    }
  }

  @override
  ValueListenable<String?> get lastApp => _lastApp;

  @override
  Future<void> updateLastApp(String? appId) async {
    await _configHandler.updateLastApp(appId);
    _lastApp.value = appId;
  }

  @override
  ValueListenable<Uri?> get privacyPolicy => _privacyPolicy;

  @override
  Future<void> updatePrivacyPolicy(Uri? policy) async {
    Uri? fallback = getAppConfig()?.privacyPolicy;
    await _configHandler.updatePrivacyPolicy(policy == fallback ? null : policy?.toString());
    _privacyPolicy.value = policy ?? fallback;
  }

  @override
  ValueListenable<String?> get currentApp => _appId;

  @override
  Future<void> updateCurrentApp(String? appId) async {
    // Only setting that also persists the default value, as this is used in the key for other settings.
    await _configHandler.updateCurrentApp(appId);
    _appId.value = appId;
    if (appId != null) {
      await updateLastApp(appId);
    }
    await _updateAppSpecificValues();
  }

  @override
  ValueListenable<String?> get appName => _appName;

  @override
  Future<void> updateAppName(String? name) async {
    String? fallback = App.getPredefinedConfig(_appId.value)?.appName;
    await _configHandler.updateAppName(
      name == fallback ? null : name?.toString(),
    );
    _appName.value = name ?? fallback;
  }

  @override
  ValueListenable<Uri?> get baseUrl => _baseUrl;

  @override
  Future<void> updateBaseUrl(Uri? baseUrl) async {
    Uri? fallback = App.getPredefinedConfig(_appId.value)?.baseUrl;
    await _configHandler.updateBaseUrl(
      baseUrl == fallback ? null : baseUrl?.toString(),
    );
    _baseUrl.value = baseUrl ?? fallback;
  }

  @override
  ValueListenable<String?> get username => _username;

  @override
  Future<void> updateUsername(String? username) async {
    String? fallback = App.getPredefinedConfig(_appId.value)?.username;
    await _configHandler.updateUsername(username == fallback ? null : username);
    _username.value = username ?? fallback;
  }

  @override
  ValueListenable<String?> get password => _password;

  @override
  Future<void> updatePassword(String? password) async {
    String? fallback = App.getPredefinedConfig(_appId.value)?.password;
    await _configHandler.updatePassword(password == fallback ? null : password);
    _password.value = password ?? fallback;
  }

  @override
  ValueListenable<String?> get title => _title;

  @override
  Future<void> updateTitle(String? title) async {
    String? fallback = App.getPredefinedConfig(_appId.value)?.title;
    await _configHandler.updateTitle(title == fallback ? null : title);
    _title.value = title ?? fallback;
  }

  @override
  ValueListenable<String?> get icon => _icon;

  @override
  Future<void> updateIcon(String? icon) async {
    String? fallback = App.getPredefinedConfig(_appId.value)?.icon;
    await _configHandler.updateIcon(icon == fallback ? null : icon);
    _icon.value = icon ?? fallback;
  }

  @override
  ValueListenable<bool?> get locked => _locked;

  @override
  ValueListenable<bool?> get parametersHidden => _parametersHidden;

  @override
  ValueListenable<String?> get authKey => _authKey;

  @override
  Future<void> updateAuthKey(String? pAuthKey) async {
    await _configHandler.updateAuthKey(pAuthKey);
    _authKey.value = pAuthKey;
  }

  @override
  ValueListenable<String?> get version => _version;

  @override
  Future<void> updateVersion(String? pVersion) async {
    await _configHandler.updateVersion(pVersion);
    _version.value = pVersion;
  }

  @override
  ValueListenable<UserInfo?> get userInfo => _userInfo;

  @override
  Future<void> updateUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson}) async {
    await _configHandler.updateUserInfo(pJson);
    _userInfo.value = pUserInfo;
  }

  @override
  String getLanguage() {
    String? language;
    if (!offline.value || (customLanguage.value ?? false)) {
      language = applicationLanguage.value;
    }
    return language ?? userLanguage.value ?? getPlatformLocale();
  }

  @override
  ValueListenable<bool?> get customLanguage => _customLanguage;

  @override
  Future<void> updateCustomLanguage(bool? customLanguage) async {
    await _configHandler.updateCustomLanguage(customLanguage);
    _customLanguage.value = customLanguage;
  }

  @override
  ValueListenable<String?> get applicationLanguage => _applicationLanguage;

  @override
  Future<void> updateApplicationLanguage(String? pLanguage) async {
    await _configHandler.updateApplicationLanguage(pLanguage);
    _applicationLanguage.value = pLanguage;
    await IUiService().i18n().setLanguage(getLanguage());
  }

  @override
  ValueListenable<String?> get userLanguage => _userLanguage;

  @override
  Future<void> updateUserLanguage(String? pLanguage) async {
    await _configHandler.updateUserLanguage(pLanguage);
    _userLanguage.value = pLanguage;
    await IUiService().i18n().setLanguage(getLanguage());
  }

  @override
  ValueListenable<Set<String>> get supportedLanguages => _supportedLanguages;

  @override
  Future<void> reloadSupportedLanguages() async {
    // Add supported languages by parsing all translation file names
    Set<String> supportedLanguage = {};

    Iterable<String> fileNames = _fileManager.listTranslationFiles().map((e) => e.path.split("/").last);
    for (String fileName in fileNames) {
      RegExpMatch? match = I18n.langRegex.firstMatch(fileName);
      if (match != null) {
        supportedLanguage.add(match.namedGroup("name")!);
      }
    }

    _supportedLanguages.value = supportedLanguage;
  }

  @override
  String getTimezone() {
    return applicationTimeZone.value ?? getPlatformTimeZone()!;
  }

  @override
  ValueListenable<String?> get applicationTimeZone => _applicationTimeZone;

  @override
  Future<void> updateApplicationTimeZone(String? timeZoneCode) async {
    await _configHandler.updateApplicationTimeZone(timeZoneCode);
    _applicationTimeZone.value = timeZoneCode;
  }

  @override
  ValueListenable<Map<String, String>?> get applicationStyle => _applicationStyle;

  @override
  Future<void> updateApplicationStyle(Map<String, String>? pAppStyle) async {
    await _configHandler.updateApplicationStyle(pAppStyle);

    // To retrieve default
    _applicationStyle.value = pAppStyle ?? await _configHandler.applicationStyle();
  }

  @override
  ThemeMode getThemeMode() {
    String? serverThemeMode = IConfigService().applicationStyle.value?["theme.mode"]?.toLowerCase();
    ThemeMode? themeMode =
        serverThemeMode == null ? null : ThemeMode.values.firstWhereOrNull((e) => e.name == serverThemeMode);
    return themeMode ?? IConfigService().themePreference.value;
  }

  @override
  double getScaling() {
    if (Frame.isWebFrame()) {
      return 1.0;
    }

    return double.parse(_applicationStyle.value?['options.mobilescaling'] ?? '2.0');
  }

  @override
  ValueListenable<bool> get offline => _offline;

  @override
  Future<void> updateOffline(bool pOffline) async {
    await _configHandler.updateOffline(pOffline);
    _offline.value = pOffline;
  }

  @override
  ValueListenable<String?> get offlineScreen => _offlineScreen;

  @override
  Future<void> updateOfflineScreen(String pWorkscreen) async {
    await _configHandler.updateOfflineScreen(pWorkscreen);
    _offlineScreen.value = pWorkscreen;
  }

  // ------------------------------

  @override
  Map<String, dynamic> getCustomStartupProperties() {
    return Map.of(_customStartupProperties);
  }

  @override
  void setCustomStartupProperties(Map<String, dynamic> pProperties) {
    _customStartupProperties = Map.of(pProperties);
  }

  @override
  void registerImagesCallback(Function() pCallback) {
    _registerCallback("images", pCallback);
  }

  @override
  void disposeImagesCallback(Function() pCallback) {
    _disposeCallback("images", pCallback);
  }

  @override
  void disposeImagesCallbacks() {
    _disposeCallbacks("images");
  }

  @override
  void imagesChanged() {
    _callbacks['images']?.forEach((element) => element.call());
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _registerCallback(String type, Function pCallback) {
    _callbacks.putIfAbsent(type, () => []).add(pCallback);
  }

  void _disposeCallback(String type, Function pCallback) {
    _callbacks[type]?.remove(pCallback);
  }

  void _disposeCallbacks(String type) {
    _callbacks[type]?.clear();
  }
}
