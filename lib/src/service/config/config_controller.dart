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

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' as universal_io;

import '../../config/app_config.dart';
import '../../flutter_ui.dart';
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

  final Map<String, dynamic> _startupParameters = {};

  AppConfig? _appConfig;

  late ValueNotifier<ThemeMode> _themePreference;

  late ValueNotifier<String?> _appName;

  late ValueNotifier<String?> _baseUrl;

  late ValueNotifier<String?> _username;

  late ValueNotifier<String?> _password;

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
    if (devConfig) {
      if (_appConfig!.serverConfig!.appName != null) {
        // Set appName first to enable the removal of the related settings.
        await _configService.updateAppName(_appConfig!.serverConfig!.appName);

        if (_appConfig!.serverConfig!.baseUrl != null) {
          await _configService.updateBaseUrl(null);
        }
        if (_appConfig!.serverConfig!.username != null) {
          await _configService.updateUsername(null);
        }
        if (_appConfig!.serverConfig!.password != null) {
          await _configService.updatePassword(null);
        }
      }
    }

    _themePreference = ValueNotifier(await _configService.themePreference());
    _pictureResolution = ValueNotifier(await _configService.pictureResolution());

    _appName = ValueNotifier(await _configService.appName());
    _baseUrl = ValueNotifier(await _configService.baseUrl() ?? _appConfig!.serverConfig!.baseUrl);
    _username = ValueNotifier(await _configService.username() ?? _appConfig!.serverConfig!.username);
    _password = ValueNotifier(await _configService.password() ?? _appConfig!.serverConfig!.password);
    _version = ValueNotifier(await _configService.version());
    _authKey = ValueNotifier(await _configService.authKey());
    _userInfo = ValueNotifier(await _configService.userInfo());
    _offline = ValueNotifier(await _configService.offline());
    _offlineScreen = ValueNotifier(await _configService.offlineScreen());
    _applicationStyle = ValueNotifier(await _configService.applicationStyle());
    _userLanguage = ValueNotifier(await _configService.userLanguage());
    _applicationTimeZone = ValueNotifier(await _configService.applicationTimeZone());

    // Trigger persisting so the config service knows about it.
    await updateAppName(await _configService.appName());

    // Update native timezone
    _platformTimeZone = await FlutterNativeTimezone.getLocalTimezone();
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Persisting methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves the current [ThemeMode] preference.
  ///
  /// Returns [ThemeMode.system] if none is configured.
  ValueNotifier<ThemeMode> get themePreference => _themePreference;

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
  ValueNotifier<int?> get pictureResolution => _pictureResolution;

  /// Sets the max. picture resolution.
  Future<void> updatePictureResolution(int pictureResolution) async {
    await _configService.updatePictureResolution(pictureResolution);
    _pictureResolution.value = pictureResolution;
  }

  /// Returns the name of the current app.
  ValueNotifier<String?> get appName => _appName;

  /// Sets the name of the current app.
  Future<void> updateAppName(String? pAppName) async {
    String? appName = pAppName ?? getAppConfig()?.serverConfig!.appName;
    // Only setting that also persists the default value, as this is used in the key for other settings.
    await _configService.updateAppName(appName);
    _appName.value = appName;
  }

  /// Returns the last saved base url.
  ///
  /// This is either:
  /// * The user entered base url.
  /// * The [ServerConfig.baseUrl] from the configured [AppConfig].
  ValueNotifier<String?> get baseUrl => _baseUrl;

  /// Sets the base url.
  ///
  /// Overrides the base url from [ServerConfig.baseUrl].
  Future<void> updateBaseUrl(String? baseUrl) async {
    await _configService.updateBaseUrl(baseUrl);
    _baseUrl.value = baseUrl ?? getAppConfig()?.serverConfig!.baseUrl;
  }

  /// Retrieves the last saved username or the configured one from [ServerConfig.username].
  ValueNotifier<String?> get username => _username;

  /// Sets the saved username.
  ///
  /// Override the username from [ServerConfig.username].
  Future<void> updateUsername(String? username) async {
    await _configService.updateUsername(username);
    _username.value = username ?? getAppConfig()?.serverConfig!.username;
  }

  /// Retrieves the last saved password or the configured one from [ServerConfig.password].
  ValueNotifier<String?> get password => _password;

  /// Sets the saved password.
  ///
  /// Override the username from [ServerConfig.password].
  Future<void> updatePassword(String? password) async {
    await _configService.updatePassword(password);
    _password.value = password ?? getAppConfig()?.serverConfig!.password;
  }

  /// Retrieves the last saved authKey, which will be used on [ApiStartUpRequest].
  ValueNotifier<String?> get authKey => _authKey;

  /// Sets the authKey.
  Future<void> updateAuthKey(String? pAuthKey) async {
    await _configService.updateAuthKey(pAuthKey);
    _authKey.value = pAuthKey;
  }

  /// Retrieves version of the current app.
  ValueNotifier<String?> get version => _version;

  /// Sets the version of the current app.
  Future<void> updateVersion(String? pVersion) async {
    await _configService.updateVersion(pVersion);
    _version.value = pVersion;
  }

  /// Returns info about the current user.
  ValueNotifier<UserInfo?> get userInfo => _userInfo;

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
  ValueNotifier<String?> get applicationLanguage => _applicationLanguage;

  /// Sets the application language code returned by the server.
  Future<void> updateApplicationLanguage(String? pLanguage) async {
    _applicationLanguage.value = pLanguage;
    loadLanguages();
  }

  /// Returns the user defined language code.
  ///
  /// To get the really used language, use [getLanguage].
  ValueNotifier<String?> get userLanguage => _userLanguage;

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
  ValueNotifier<Set<String>> get supportedLanguages => _supportedLanguages;

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
  ValueNotifier<String?> get applicationTimeZone => _applicationTimeZone;

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
  ValueNotifier<Map<String, String>> get applicationStyle => _applicationStyle;

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
  ValueNotifier<bool> get offline => _offline;

  /// Sets the offline mode.
  Future<void> updateOffline(bool pOffline) async {
    await _configService.updateOffline(pOffline);
    _offline.value = pOffline;
  }

  /// Returns the screen to which the offline data has to be synced back.
  ///
  /// Is only available while being offline ([offline]).
  /// Normally this is the same as the last open screen when going offline.
  ValueNotifier<String?> get offlineScreen => _offlineScreen;

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
  Map<String, dynamic> getStartupParameters() {
    return _startupParameters;
  }

  /// Set a custom startup parameter.
  ///
  /// See also:
  /// * [getStartupParameters]
  Future<void> updateStartupParameter({required String pKey, required dynamic pValue}) async {
    _startupParameters[pKey] = pValue;
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
    File? defaultTransFile = _fileManager.getFileSync(pPath: "${IFileManager.LANGUAGES_PATH}/translation.json");
    langTrans.merge(defaultTransFile);

    if (pLanguage != "en") {
      File? transFile = _fileManager.getFileSync(pPath: "${IFileManager.LANGUAGES_PATH}/translation_$pLanguage.json");
      if (transFile == null) {
        FlutterUI.logUI.v("Translation file for code $pLanguage could not be found");
      } else {
        langTrans.merge(transFile);
      }
    }

    _translation = langTrans;
  }
}
