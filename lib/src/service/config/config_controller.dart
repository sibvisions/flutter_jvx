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

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' as universal_io;

import '../../config/app_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../mask/apps/app_overview_page.dart';
import '../../mask/frame/frame.dart';
import '../../mask/state/app_style.dart';
import '../../model/config/translation/translation_util.dart';
import '../../model/config/user/user_info.dart';
import '../../model/request/api_startup_request.dart';
import '../../model/response/download_images_response.dart';
import '../../model/response/download_style_response.dart';
import '../file/file_manager.dart';
import '../service.dart';
import 'config_service.dart';

/// Allows to read user settings, update user settings, or listen
/// to user settings changes.
class ConfigController {
  static final RegExp langRegex = RegExp("_(?<name>[a-z]+)");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final ConfigService _configService;

  /// Used to manage files, different implementations for web and mobile.
  final IFileManager _fileManager;

  /// Map of all active callbacks.
  final Map<String, List<Function>> _callbacks = {};

  final Map<String, dynamic> _customStartUpProperties = {};

  AppConfig? _appConfig;

  late ValueNotifier<ThemeMode> _themePreference;

  late ValueNotifier<bool> _singleAppMode;

  late ValueNotifier<String?> _defaultApp;

  late ValueNotifier<String?> _lastApp;

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
  late ValueNotifier<Map<String, String>> _applicationStyle;

  late ValueNotifier<String?> _userLanguage;

  late ValueNotifier<String?> _applicationTimeZone;

  late ValueNotifier<int?> _pictureResolution;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Non-persistent fields (fields that don't use a backend service)
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Current translation, base translation + overlaid language.
  TranslationUtil _translation = TranslationUtil.empty();

  String? _platformTimeZone;

  final ValueNotifier<String?> _applicationLanguage = ValueNotifier(null);

  final ValueNotifier<Set<String>> _supportedLanguages = ValueNotifier({});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the singleton instance.
  factory ConfigController() => services<ConfigController>();

  ConfigController.create({
    required IFileManager fileManager,
    required ConfigService configService,
  })  : _configService = configService,
        _fileManager = fileManager;

  /// Loads the initial config.
  ///
  /// If [devConfig] is true, this call removes all saved values for [ServerConfig]
  /// which would prevent the default config to be used.
  Future<void> loadConfig(AppConfig pAppConfig, [bool devConfig = false]) async {
    _appConfig = pAppConfig;

    // DevConfig resets persistent fields to enable config-fallback logic.
    if (devConfig && _appConfig?.serverConfigs != null) {
      await Future.forEach<ServerConfig>(
        _appConfig!.serverConfigs!.where((e) => e.appName != null),
        (e) => removeApp(e.appName!),
      );
    }

    _themePreference = ValueNotifier(await _configService.themePreference());
    _pictureResolution = ValueNotifier(await _configService.pictureResolution());
    _singleAppMode = ValueNotifier(await _configService.singleAppMode());
    _defaultApp = ValueNotifier(await _configService.defaultApp());
    _lastApp = ValueNotifier(await _configService.lastApp());

    ServerConfig? defaultConfig = _appConfig?.serverConfigs!.firstWhereOrNull((e) => e.appName == _defaultApp.value) ??
        _appConfig?.serverConfigs!.firstOrNull;

    _appName = ValueNotifier(await _configService.appName() ?? defaultConfig?.appName);

    ServerConfig? predefinedApp = getPredefinedApp(_appName.value);
    bool isPredefined = predefinedApp != null;
    bool useUserSettings = AppOverviewPage.useUserSettings(
      _appConfig!.serverConfigsParametersHidden! || _appConfig!.serverConfigsLocked!,
      isPredefined,
      predefinedApp,
    );

    String? baseUrl = await _configService.baseUrl();
    _baseUrl = ValueNotifier(
        (useUserSettings ? (baseUrl != null ? Uri.parse(baseUrl) : null) : null) ?? predefinedApp?.baseUrl);
    _username = ValueNotifier(await _configService.username() ?? predefinedApp?.username);
    _password = ValueNotifier(await _configService.password() ?? predefinedApp?.password);
    _title = ValueNotifier((useUserSettings ? await _configService.title() : null) ?? predefinedApp?.title);
    _icon = ValueNotifier(await _configService.icon() ?? predefinedApp?.icon);
    _locked = ValueNotifier(predefinedApp?.locked);
    _parametersHidden = ValueNotifier(predefinedApp?.parametersHidden);
    _version = ValueNotifier(await _configService.version());
    _authKey = ValueNotifier(await _configService.authKey());
    _userInfo = ValueNotifier(await _configService.userInfo());
    _offline = ValueNotifier(await _configService.offline());
    _offlineScreen = ValueNotifier(await _configService.offlineScreen());
    _applicationStyle = ValueNotifier(await _configService.applicationStyle());
    _userLanguage = ValueNotifier(await _configService.userLanguage());
    _applicationTimeZone = ValueNotifier(await _configService.applicationTimeZone());

    // Allow and trigger persisting in the config service.
    if (_appName.value != null) {
      await updateAppName(_appName.value!);
    }

    // Update native timezone
    _platformTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  }

  Future<void> _updateAppSpecificValues() async {
    final String? appName = _appName.value;
    ServerConfig? predefinedApp = getPredefinedApp(appName);
    bool isPredefined = predefinedApp != null;
    bool useUserSettings = AppOverviewPage.useUserSettings(
      _appConfig!.serverConfigsParametersHidden! || _appConfig!.serverConfigsLocked!,
      isPredefined,
      predefinedApp,
    );

    String? baseUrl = await _configService.baseUrl();
    _baseUrl.value = (useUserSettings ? (baseUrl != null ? Uri.parse(baseUrl) : null) : null) ?? predefinedApp?.baseUrl;
    _username.value = await _configService.username() ?? predefinedApp?.username;
    _password.value = await _configService.password() ?? predefinedApp?.password;
    _title.value = (useUserSettings ? await _configService.title() : null) ?? predefinedApp?.title;
    _icon.value = await _configService.icon() ?? predefinedApp?.icon;
    _locked.value = predefinedApp?.locked;
    _parametersHidden.value = predefinedApp?.parametersHidden;
    _version.value = await _configService.version();
    _authKey.value = await _configService.authKey();
    _userInfo.value = await _configService.userInfo();
    _offline.value = await _configService.offline();
    _offlineScreen.value = await _configService.offlineScreen();
    _applicationStyle.value = await _configService.applicationStyle();
    _userLanguage.value = await _configService.userLanguage();
    _applicationTimeZone.value = await _configService.applicationTimeZone();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Helper-methods for non-persistent fields
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Translates [pText] using [TranslationUtil] in the current language as defined by [getLanguage].
  String translateText(String pText) {
    return _translation.translateText(pText);
  }

  /// Returns the current in use [SharedPreferences] instance.
  SharedPreferences getSharedPreferences() {
    return _configService.getSharedPreferences();
  }

  /// Returns the current [IFileManager] in use.
  IFileManager getFileManager() {
    return _fileManager;
  }

  /// Retrieves the platform locale using [Platform.localeName].
  String getPlatformLocale() {
    int? end = universal_io.Platform.localeName.indexOf(RegExp("[_-]"));
    return universal_io.Platform.localeName.substring(0, end == -1 ? null : end);
  }

  /// Returns the cached platform timezone (retrieved via [FlutterNativeTimezone.getLocalTimezone]).
  String? getPlatformTimeZone() {
    return _platformTimeZone;
  }

  /// Returns the phone size determined by [MediaQueryData.size].
  Size? getPhoneSize() {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
  }

  /// Returns the initial configured app config.
  ///
  /// To get up to date values, use their respective getters:
  /// * [baseUrl]
  /// * [appName]
  /// * [username]
  /// * [password]
  AppConfig? getAppConfig() {
    return _appConfig;
  }

  /// Returns a list of all known app names.
  ///
  /// Attention: This list doesn't provide any information about the validity
  /// of these apps, they don't have to be "start-able" (meaning there is a base url).
  Set<String> getAppNames() {
    List<String>? externalConfigs =
        _appConfig?.serverConfigs?.where((e) => e.appName != null).map((e) => e.appName!).toList();
    return {
      ..._configService.getAppNames(),
      ...?externalConfigs,
    };
  }

  /// Returns a [ServerConfig] populated on a best-effort-basis for the requested app.
  ///
  /// Could potentially be completely empty besides the provided [appName]!
  /// Combines the configs from [getPredefinedApp] and [getStoredApp].
  Future<ServerConfig> getApp(String? appName) async {
    if (appName == null) return const ServerConfig.empty();
    return const ServerConfig.empty().merge(getPredefinedApp(appName)).merge(await getStoredApp(appName));
  }

  String? getAppVersion(String? appName) {
    if (appName == null) return null;
    return _configService.getAppVersion(appName);
  }

  Map<String, String>? getAppStyle(String? appName) {
    if (appName == null) return null;
    return _configService.getAppStyle(appName);
  }

  Future<ServerConfig?> getStoredApp(String? appName) async => appName == null ? null : _configService.getApp(appName);

  ServerConfig? getPredefinedApp(String? appName) =>
      appName == null ? null : _appConfig?.serverConfigs!.firstWhereOrNull((e) => e.appName == appName);

  /// Adds/Updates this config in the persistent storage.
  ///
  /// In case of renaming an existing app, provide an [oldAppName].
  Future<void> updateApp(ServerConfig config, {String? oldAppName}) async {
    if (config.appName?.isNotEmpty ?? false) {
      ServerConfig? localConfig = getPredefinedApp(config.appName!);
      assert(!(localConfig?.locked ?? false));

      if (localConfig == config) {
        return _configService.removeApp(config.appName!);
      }

      return _configService.updateApp(
        oldAppName,
        // AppName has to be provided nonetheless!
        config.diff(localConfig).merge(ServerConfig(
              appName: config.appName,
            )),
        removeNullFields: true,
      );
    }
  }

  /// Removes all preferences of this app.
  Future<void> removeApp(String appName) async {
    ServerConfig? localConfig = getPredefinedApp(appName);
    assert(!(localConfig?.locked ?? false));

    return _configService.removeApp(appName);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Persisting methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves the current [ThemeMode] preference.
  ///
  /// Returns [ThemeMode.system] if none is configured.
  ValueListenable<ThemeMode> get themePreference => _themePreference;

  /// Sets the current [ThemeMode] preference.
  ///
  /// If [themeMode] is [ThemeMode.system], the preference will be set to `null`.
  Future<void> updateThemePreference(ThemeMode themeMode) async {
    await _configService.updateThemePreference(themeMode);
    _themePreference.value = themeMode;
  }

  /// Retrieves the configured max. picture resolution.
  ///
  /// This is being used to limit the resolution of pictures taken via the in-app camera.
  ValueListenable<int?> get pictureResolution => _pictureResolution;

  /// Sets the max. picture resolution.
  Future<void> updatePictureResolution(int pictureResolution) async {
    await _configService.updatePictureResolution(pictureResolution);
    _pictureResolution.value = pictureResolution;
  }

  /// Returns the last opened app.
  ValueListenable<bool> get singleAppMode => _singleAppMode;

  /// Sets the last opened app.
  Future<void> updateSingleAppMode(bool? singleAppMode) async {
    await _configService.updateSingleAppMode(singleAppMode);
    _singleAppMode.value = singleAppMode ?? await _configService.singleAppMode();
  }

  /// Returns the default app.
  ValueListenable<String?> get defaultApp => _defaultApp;

  /// Sets the default app.
  Future<void> updateDefaultApp(String? appName) async {
    await _configService.updateDefaultApp(appName);
    _defaultApp.value = appName;
  }

  /// Returns the last opened app.
  ValueListenable<String?> get lastApp => _lastApp;

  /// Sets the last opened app.
  Future<void> updateLastApp(String? appName) async {
    await _configService.updateLastApp(appName);
    _lastApp.value = appName;
  }

  /// Returns the name of the current app.
  ValueListenable<String?> get appName => _appName;

  /// Sets the name of the current app.
  Future<void> updateAppName(String? appName) async {
    // Only setting that also persists the default value, as this is used in the key for other settings.
    await _configService.updateAppName(appName);
    _appName.value = appName;
    await _updateAppSpecificValues();
  }

  /// Returns the saved base url.
  ///
  /// This is either:
  /// * The user entered base url.
  /// * The [ServerConfig.baseUrl] from the configured [AppConfig].
  ValueListenable<Uri?> get baseUrl => _baseUrl;

  /// Sets the base url.
  ///
  /// Overrides the base url from [AppConfig.serverConfigs].
  Future<void> updateBaseUrl(Uri? baseUrl) async {
    Uri? fallback = getPredefinedApp(_appName.value)?.baseUrl;
    await _configService.updateBaseUrl(
      baseUrl == fallback ? null : baseUrl?.toString(),
    );
    _baseUrl.value = baseUrl ?? fallback;
  }

  /// Retrieves the last saved username or the configured one from [AppConfig.serverConfigs].
  ValueListenable<String?> get username => _username;

  /// Sets the saved username.
  ///
  /// Overrides the username from [AppConfig.serverConfigs].
  Future<void> updateUsername(String? username) async {
    String? fallback = getPredefinedApp(_appName.value)?.username;
    await _configService.updateUsername(username == fallback ? null : username);
    _username.value = username ?? fallback;
  }

  /// Retrieves the last saved password or the configured one from [AppConfig.serverConfigs].
  ValueListenable<String?> get password => _password;

  /// Sets the saved password.
  ///
  /// Overrides the password from [AppConfig.serverConfigs].
  Future<void> updatePassword(String? password) async {
    String? fallback = getPredefinedApp(_appName.value)?.password;
    await _configService.updatePassword(password == fallback ? null : password);
    _password.value = password ?? fallback;
  }

  /// Retrieves the saved title.
  ValueListenable<String?> get title => _title;

  /// Sets the title.
  ///
  /// Overrides the title from [AppConfig.serverConfigs].
  Future<void> updateTitle(String? title) async {
    String? fallback = getPredefinedApp(_appName.value)?.title;
    await _configService.updateTitle(title == fallback ? null : title);
    _title.value = title ?? fallback;
  }

  /// Retrieves the saved icon.
  ValueListenable<String?> get icon => _icon;

  /// Sets the icon.
  ///
  /// Overrides the icon from [AppConfig.serverConfigs].
  Future<void> updateIcon(String? icon) async {
    String? fallback = getPredefinedApp(_appName.value)?.icon;
    await _configService.updateIcon(icon == fallback ? null : icon);
    _icon.value = icon ?? fallback;
  }

  /// Whether this app config is locked.
  ValueListenable<bool?> get locked => _locked;

  /// Whether this app config is hidden.
  ValueListenable<bool?> get parametersHidden => _parametersHidden;

  /// Retrieves the last saved authKey, which will be used on [ApiStartUpRequest].
  ValueListenable<String?> get authKey => _authKey;

  /// Sets the authKey.
  Future<void> updateAuthKey(String? pAuthKey) async {
    await _configService.updateAuthKey(pAuthKey);
    _authKey.value = pAuthKey;
  }

  /// Retrieves version of the current app.
  ValueListenable<String?> get version => _version;

  /// Sets the version of the current app.
  Future<void> updateVersion(String? pVersion) async {
    await _configService.updateVersion(pVersion);
    _version.value = pVersion;
  }

  /// Returns info about the current user.
  ValueListenable<UserInfo?> get userInfo => _userInfo;

  /// Sets the current user info.
  Future<void> updateUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson}) async {
    await _configService.updateUserInfo(pJson);
    _userInfo.value = pUserInfo;
  }

  /// Returns the language which should be used to translate text shown to the user.
  ///
  /// This is either:
  /// * The server set language (which in most cases the same as we send in the startup).
  /// * The user chosen language.
  /// * The platform locale (determined by [getPlatformLocale]).
  String getLanguage() {
    return applicationLanguage.value ?? userLanguage.value ?? getPlatformLocale();
  }

  /// Returns the application language code returned by the server.
  ///
  /// Returns `null` before initial startup.
  ValueListenable<String?> get applicationLanguage => _applicationLanguage;

  /// Sets the application language code returned by the server.
  Future<void> updateApplicationLanguage(String? pLanguage) async {
    _applicationLanguage.value = pLanguage;
    loadLanguages();
  }

  /// Returns the user defined language code.
  ///
  /// To get the really used language, use [getLanguage].
  ValueListenable<String?> get userLanguage => _userLanguage;

  /// Set the user defined language code.
  Future<void> updateUserLanguage(String? pLanguage) async {
    await _configService.updateUserLanguage(pLanguage);
    _userLanguage.value = pLanguage;
    loadLanguages();
  }

  /// Initializes the current language defined by [getLanguage].
  void loadLanguages() {
    if (_fileManager.isSatisfied()) {
      final String pLanguage = getLanguage();
      _loadTranslations(pLanguage);
      _callbacks['language']?.forEach((element) => element.call(pLanguage));
    }
  }

  /// Returns all currently supported languages by this application.
  ValueListenable<Set<String>> get supportedLanguages => _supportedLanguages;

  /// Refreshes the supported languages by checking the local translation folder.
  ///
  /// See also:
  /// * [supportedLanguages]
  void reloadSupportedLanguages() {
    // Add supported languages by parsing all translation file names
    Set<String> supportedLanguage = {};
    List<File> listFiles = _fileManager.getTranslationFiles();

    for (File file in listFiles) {
      String fileName = file.path.split("/").last;
      RegExpMatch? match = langRegex.firstMatch(fileName);
      if (match != null) {
        supportedLanguage.add(match.namedGroup("name")!);
      }
    }

    _supportedLanguages.value = supportedLanguage;
  }

  /// Returns the timezone which should be used to calculate dates/times shown to the user.
  ///
  /// This is either:
  /// * The server defined timezone (which in most cases the same as we send in the [ApiStartUpRequest]).
  /// * The platform timezone (determined by [getPlatformTimeZone]).
  String getTimezone() {
    return applicationTimeZone.value ?? getPlatformTimeZone()!;
  }

  /// Returns the application timezone returned by the server.
  ValueListenable<String?> get applicationTimeZone => _applicationTimeZone;

  /// Set the application defined timezone.
  Future<void> updateApplicationTimeZone(String? timeZoneCode) async {
    await _configService.updateApplicationTimeZone(timeZoneCode);
    _applicationTimeZone.value = timeZoneCode;
  }

  /// Returns the last saved app style.
  ///
  /// Use [AppStyle] instead when used in Widgets.
  ///
  /// See also:
  /// * [AppStyle]
  /// * [updateApplicationStyle]
  ValueListenable<Map<String, String>> get applicationStyle => _applicationStyle;

  /// Sets the app style.
  ///
  /// Calls the style callbacks.
  /// This will also be persisted for offline usage.
  ///
  /// See also:
  /// * [DownloadStyleResponse]
  Future<void> updateApplicationStyle(Map<String, String>? pAppStyle) async {
    await _configService.updateApplicationStyle(pAppStyle);

    // To retrieve default
    _applicationStyle.value = pAppStyle ?? await _configService.applicationStyle();
  }

  /// Returns the scaling multiplier for server sent sizes
  double getScaling() {
    if (Frame.isWebFrame()) {
      return 1.0;
    }

    return double.parse(_applicationStyle.value['options.mobilescaling'] ?? '2.0');
  }

  /// Returns if the app is currently in offline mode.
  ValueListenable<bool> get offline => _offline;

  /// Sets the offline mode.
  Future<void> updateOffline(bool pOffline) async {
    await _configService.updateOffline(pOffline);
    _offline.value = pOffline;
  }

  /// Returns the screen to which the offline data has to be synced back.
  ///
  /// Is only available while being offline ([offline]).
  /// Normally this is the same as the last open screen when going offline.
  ValueListenable<String?> get offlineScreen => _offlineScreen;

  /// Sets the screen to which the offline data has to be synced back.
  Future<void> updateOfflineScreen(String pWorkscreen) async {
    await _configService.updateOfflineScreen(pWorkscreen);
    _offlineScreen.value = pWorkscreen;
  }

  // ------------------------------

  /// Returns a map of all custom parameters which are sent on every [ApiStartUpRequest].
  ///
  /// See also:
  /// * [ApiStartUpRequest]
  Map<String, dynamic> getCustomStartUpProperties() {
    return _customStartUpProperties;
  }

  /// Set a custom startup parameter.
  ///
  /// See also:
  /// * [getCustomStartUpProperties]
  void updateCustomStartUpProperties(String pKey, dynamic pValue) {
    _customStartUpProperties[pKey] = pValue;
  }

  /// Register a callback that will be called when the current language changes.
  ///
  /// See also:
  /// * [getLanguage]
  void registerLanguageCallback(Function(String language) pCallback) {
    _registerCallback("language", pCallback);
  }

  /// Dispose a language callback.
  void disposeLanguageCallback(Function(String language) pCallback) {
    _disposeCallback("language", pCallback);
  }

  /// Dispose all language callbacks.
  void disposeLanguageCallbacks() {
    _disposeCallbacks("language");
  }

  /// Register a callback that will be called when the locally saved images change.
  ///
  /// See also:
  /// * [DownloadImagesResponse]
  void registerImagesCallback(Function() pCallback) {
    _registerCallback("images", pCallback);
  }

  /// Dispose an image callback.
  void disposeImagesCallback(Function() pCallback) {
    _disposeCallback("images", pCallback);
  }

  /// Dispose all image callbacks.
  void disposeImagesCallbacks() {
    _disposeCallbacks("images");
  }

  /// Triggers all image callbacks.
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

  void _loadTranslations(String pLanguage) {
    TranslationUtil langTrans = TranslationUtil.empty();

    // Load the default translation.
    String defaultTransFilePath = _fileManager.getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/translation.json");
    File? defaultTransFile = _fileManager.getFileSync(defaultTransFilePath);
    langTrans.merge(defaultTransFile);

    if (pLanguage != "en") {
      String transFilePath =
          _fileManager.getAppSpecificPath("${IFileManager.LANGUAGES_PATH}/translation_$pLanguage.json");
      File? transFile = _fileManager.getFileSync(transFilePath);
      if (transFile == null) {
        FlutterUI.logUI.v("Translation file for code $pLanguage could not be found");
      } else {
        langTrans.merge(transFile);
      }
    }

    _translation = langTrans;
  }
}
