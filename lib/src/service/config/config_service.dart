/* Copyright 2022 SIB Visions GmbH
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

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' as universal_io;

import '../../config/app_config.dart';
import '../../flutter_ui.dart';
import '../../mask/frame/frame.dart';
import '../../mask/state/app_style.dart';
import '../../model/config/translation/translation.dart';
import '../../model/config/user/user_info.dart';
import '../../model/request/api_startup_request.dart';
import '../../model/response/application_meta_data_response.dart';
import '../../model/response/application_settings_response.dart';
import '../../model/response/device_status_response.dart';
import '../../model/response/download_images_response.dart';
import '../../model/response/download_style_response.dart';
import '../file/file_manager.dart';
import '../service.dart';

/// Stores all config and session based data.
///
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
class ConfigService {
  static final RegExp langRegex = RegExp("_(?<name>[a-z]+)");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Set<String> _supportedLanguages = {};

  final SharedPreferences _sharedPrefs;

  final Map<String, dynamic> _startupParameters = {};

  /// Map of all active callbacks.
  final Map<String, List<Function>> _callbacks = {};

  /// Used to manage files, different implementations for web and mobile.
  final IFileManager _fileManager;

  /// The last layoutMode from the server.
  final ValueNotifier<LayoutMode> _layoutMode = ValueNotifier(kIsWeb ? LayoutMode.Full : LayoutMode.Mini);

  /// The current offline state.
  ValueNotifier<bool>? _offlineNotifier;

  AppConfig? _appConfig;

  /// JVx Application Metadata.
  ApplicationMetaDataResponse? _metaData;

  /// Current clientId (sessionId).
  String? _clientId;

  /// UserInfo about the current user.
  UserInfo? _userInfo;

  String? _language;

  String? _localTimeZone;

  /// Current translation, base translation + overlaid language.
  Translation _translation = Translation.empty();

  /// Application style sent from server.
  Map<String, String>? _applicationStyle;

  /// JVx Application Settings.
  ApplicationSettingsResponse _applicationSettings = ApplicationSettingsResponse.empty();

  bool _mobileOnly = false;

  bool _webOnly = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the singleton instance.
  factory ConfigService() => services<ConfigService>();

  ConfigService.create({
    required IFileManager fileManager,
    required SharedPreferences sharedPrefs,
  })  : _sharedPrefs = sharedPrefs,
        _fileManager = fileManager;

  /// Retrieves the platform locale using [Platform.localeName].
  String getPlatformLocale() {
    int? end = universal_io.Platform.localeName.indexOf(RegExp("[_-]"));
    return universal_io.Platform.localeName.substring(0, end == -1 ? null : end);
  }

  /// Returns the saved platform timezone (retrieves via [FlutterNativeTimezone.getLocalTimezone]).
  String getPlatformTimeZone() {
    return _localTimeZone!;
  }

  /// Sets the native time zone for later use (to avoid async call to [FlutterNativeTimezone.getLocalTimezone]).
  void setLocalTimeZone(String? timeZone) {
    _localTimeZone = timeZone;
  }

  /// Returns the current in use [SharedPreferences] instance.
  SharedPreferences getSharedPreferences() {
    return _sharedPrefs;
  }

  /// Returns the current clientId.
  ///
  /// `null` if none is present.
  String? getClientId() {
    return _clientId;
  }

  void setClientId(String? pClientId) {
    _clientId = pClientId;
  }

  /// Returns the last known [ApplicationMetaDataResponse].
  ApplicationMetaDataResponse? getMetaData() {
    return _metaData;
  }

  void setMetaData(ApplicationMetaDataResponse? pMetaData) {
    _metaData = pMetaData;
  }

  /// Retrieves version of the current app.
  String? getVersion() {
    return getString("version");
  }

  /// Sets the version of the current app.
  Future<bool> setVersion(String? pVersion) {
    return setString("version", pVersion);
  }

  /// Returns info about the current user.
  UserInfo? getUserInfo() {
    _loadUserInfo();
    return _userInfo;
  }

  /// Sets the current user info.
  Future<bool> setUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson}) {
    _userInfo = pUserInfo;
    return setString("userInfo", pJson != null ? jsonEncode(pJson) : null);
  }

  /// Returns the name of the current app.
  String? getAppName() {
    return _sharedPrefs.getString("appName") ?? getAppConfig()?.serverConfig!.appName;
  }

  /// Sets the name of the current app.
  Future<bool> setAppName(String? pAppName) {
    if (pAppName == null) return _sharedPrefs.remove("appName");
    return _sharedPrefs.setString("appName", pAppName);
  }

  /// Returns the current [IFileManager] in use.
  IFileManager getFileManager() {
    return _fileManager;
  }

  /// Returns the language which should be used to translate text shown to the user.
  ///
  /// This is either:
  /// * The server set language (which in most cases the same as we send in the startup).
  /// * The user chosen language.
  /// * The platform locale (determined by [getPlatformLocale]).
  String getLanguage() {
    return getApplicationLanguage() ?? getUserLanguage() ?? getPlatformLocale();
  }

  /// Returns the application language code returned by the server.
  ///
  /// Returns `null` before initial startup.
  String? getApplicationLanguage() {
    return _language;
  }

  /// Sets the application language code returned by the server.
  void setApplicationLanguage(String? pLanguage) {
    _language = pLanguage;
    if (_fileManager.isSatisfied()) {
      loadLanguages();
    }
  }

  /// Returns the user defined language code.
  ///
  /// To get the really used language, use [getLanguage].
  String? getUserLanguage() {
    return getString("language");
  }

  /// Set the user defined language code.
  Future<bool> setUserLanguage(String? pLanguage) async {
    bool success = await setString("language", pLanguage);
    if (_fileManager.isSatisfied()) {
      loadLanguages();
    }
    return success;
  }

  /// Initializes the current language defined by [getLanguage].
  void loadLanguages() {
    _loadLanguage(getLanguage());
  }

  /// Returns all currently supported languages by this application.
  Set<String> getSupportedLanguages() {
    return _supportedLanguages;
  }

  /// Refreshes the supported languages by checking the local translation folder.
  ///
  /// See also:
  /// * [getSupportedLanguages]
  void reloadSupportedLanguages() {
    // Add supported languages by parsing all translation file names
    _supportedLanguages.clear();

    List<File> listFiles = _fileManager.getTranslationFiles();

    for (File file in listFiles) {
      String fileName = file.path.split("/").last;
      RegExpMatch? match = langRegex.firstMatch(fileName);
      if (match != null) {
        _supportedLanguages.add(match.namedGroup("name")!);
      }
    }
  }

  /// Returns the timezone which should be used to calculate dates/times shown to the user.
  ///
  /// This is either:
  /// * The server defined timezone (which in most cases the same as we send in the [ApiStartUpRequest]).
  /// * The platform timezone (determined by [getPlatformTimeZone]).
  String getTimezone() {
    return getApplicationTimeZone() ?? getPlatformTimeZone();
  }

  /// Returns the application timezone returned by the server.
  String? getApplicationTimeZone() {
    return getString("timeZoneCode");
  }

  /// Set the application defined timezone.
  Future<bool> setApplicationTimeZone(String? timeZoneCode) {
    return setString("timeZoneCode", timeZoneCode);
  }

  /// Returns the last saved base url.
  ///
  /// This is either:
  /// * The user entered base url.
  /// * The [ServerConfig.baseUrl] from the configured [AppConfig].
  String? getBaseUrl() {
    return getString("baseUrl") ?? getAppConfig()?.serverConfig!.baseUrl;
  }

  /// Sets the base url.
  ///
  /// Overrides the base url from [ServerConfig.baseUrl].
  Future<bool> setBaseUrl(String? baseUrl) {
    return setString("baseUrl", baseUrl);
  }

  /// Retrieves the last saved username or the configured one from [ServerConfig.username].
  String? getUsername() {
    return getString("username") ?? getAppConfig()?.serverConfig!.username;
  }

  /// Sets the saved username.
  ///
  /// Override the username from [ServerConfig.username].
  Future<bool> setUsername(String? username) {
    return setString("username", username);
  }

  /// Retrieves the last saved password or the configured one from [ServerConfig.password].
  String? getPassword() {
    return getString("password") ?? getAppConfig()?.serverConfig!.password;
  }

  /// Sets the saved password.
  ///
  /// Override the username from [ServerConfig.password].
  Future<bool> setPassword(String? password) {
    return setString("password", password);
  }

  /// Retrieves the last saved authKey, which will be used on [ApiStartUpRequest].
  String? getAuthCode() {
    return getString("authKey");
  }

  /// Sets the authKey.
  Future<bool> setAuthCode(String? pAuthCode) {
    return setString("authKey", pAuthCode);
  }

  /// Returns the last saved app style.
  ///
  /// Use [AppStyle] instead when used in Widgets.
  Map<String, String> getAppStyle() {
    _loadAppStyle();
    return _applicationStyle!;
  }

  /// Sets the app style.
  ///
  /// Calls the style callbacks.
  /// This will also be persisted for offline usage.
  ///
  /// See also:
  /// * [DownloadStyleResponse]
  Future<bool> setAppStyle(Map<String, String>? pAppStyle) async {
    if (pAppStyle == null) {
      _applicationStyle?.clear();
    } else {
      _applicationStyle = pAppStyle;
    }

    bool success = await setString("applicationStyle", pAppStyle != null ? jsonEncode(pAppStyle) : null);

    _callbacks['style']?.forEach((element) => element.call());
    return success;
  }

  // TODO: Replace usages with [AppStyle]
  double getOpacityMenu() {
    _loadAppStyle();
    return double.parse(_applicationStyle!['opacity.menu'] ?? '1');
  }

  // TODO: Replace usages with [AppStyle]
  double getOpacitySideMenu() {
    _loadAppStyle();
    return double.parse(_applicationStyle!['opacity.sidemenu'] ?? '1');
  }

  // TODO: Replace usages with [AppStyle]
  double getOpacityControls() {
    _loadAppStyle();
    return double.parse(_applicationStyle!['opacity.controls'] ?? '1');
  }

  /// Retrieves the configured max. picture resolution.
  ///
  /// This is being used to limit the resolution of pictures taken via the in-app camera.
  int? getPictureResolution() {
    return _sharedPrefs.getInt("${getAppName()}.pictureSize");
  }

  /// Sets the max. picture resolution.
  Future<bool> setPictureResolution(int pictureResolution) {
    assert(getAppName() != null);
    return _sharedPrefs.setInt("${getAppName()}.pictureSize", pictureResolution);
  }

  /// Returns if the app is currently in offline mode.
  ///
  /// To receive continuous updates, use [getOfflineNotifier] instead.
  bool isOffline() {
    return _offlineNotifier?.value ?? _sharedPrefs.getBool("${getAppName()}.offline") ?? false;
  }

  /// Returns a notifier get updates about the app's offline mode.
  ///
  /// [isOffline] can be used to retrieve one-time values.
  ValueNotifier<bool> getOfflineNotifier() {
    _offlineNotifier ??= ValueNotifier(isOffline());
    return _offlineNotifier!;
  }

  /// Sets the offline mode.
  Future<bool> setOffline(bool pOffline) {
    assert(getAppName() != null);
    _offlineNotifier?.value = pOffline;
    return _sharedPrefs.setBool("${getAppName()}.offline", pOffline);
  }

  /// Returns the screen to which the offline data has to be synced back.
  ///
  /// Is only available while being offline ([isOffline] respectively [getOfflineNotifier]).
  /// Normally this is the same as the last open screen when going offline.
  String? getOfflineScreen() {
    return getString("offlineScreen");
  }

  /// Sets the screen to which the offline data has to be synced back.
  Future<bool> setOfflineScreen(String pWorkscreen) {
    return setString("offlineScreen", pWorkscreen);
  }

  /// Retrieves a string value by it's key in connection to the current app name from [SharedPreferences].
  ///
  /// The key is structured as follows:
  /// ```dart
  /// "$appName.$key"
  /// ```
  String? getString(String key) {
    return _sharedPrefs.getString("${getAppName()}.$key");
  }

  /// Persists a string value by it's key in connection to the current app name in [SharedPreferences].
  ///
  /// The key is structured as follows:
  /// ```dart
  /// "$appName.$key"
  /// ```
  ///
  /// `null` removes the value from the storage.
  Future<bool> setString(String key, String? value) {
    assert(getAppName() != null);
    if (value != null) {
      return _sharedPrefs.setString("${getAppName()}.$key", value);
    } else {
      return _sharedPrefs.remove("${getAppName()}.$key");
    }
  }

  // ------------------------------

  /// Translates [pText] using the current language as defined by [getLanguage].
  ///
  /// Returns the original value if not translation was found.
  String translateText(String pText) {
    String? translatedText = _translation.translations[pText];
    if (translatedText == null) {
      return pText;
    }
    return translatedText;
  }

  /// Returns the initial configured app config.
  ///
  /// To get up to date values, use their respective getters:
  /// * [getBaseUrl]
  /// * [getAppName]
  /// * [getUsername]
  /// * [getPassword]
  AppConfig? getAppConfig() {
    return _appConfig;
  }

  /// Sets the initial app config.
  ///
  /// DO NOT USE THIS to update [ServerConfig] fields!
  ///
  /// If [devConfig] is true, this call removes all saved values which would override this config.
  Future<void> setAppConfig(AppConfig? pAppConfig, [bool devConfig = false]) async {
    _appConfig = pAppConfig;
    if (devConfig) {
      if (pAppConfig?.serverConfig!.appName != null) {
        await setAppName(null);
      }
      if (pAppConfig?.serverConfig!.baseUrl != null) {
        await setBaseUrl(null);
      }
      if (pAppConfig?.serverConfig!.username != null) {
        await setUsername(null);
      }
      if (pAppConfig?.serverConfig!.password != null) {
        await setPassword(null);
      }
    }
  }

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
  void setStartupParameter({required String pKey, required dynamic pValue}) {
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

  /// Register a callback that will be called when the current app style changes.
  ///
  /// See also:
  /// * [AppStyle]
  /// * [getAppStyle]
  /// * [setAppStyle]
  void registerStyleCallback(Function() pCallback) {
    _registerCallback("style", pCallback);
  }

  /// Dispose a style callback.
  void disposeStyleCallback(Function() pCallback) {
    _disposeCallback("style", pCallback);
  }

  /// Dispose all style callbacks.
  void disposeStyleCallbacks() {
    _disposeCallbacks("style");
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

  /// Returns the phone size determined by [MediaQueryData.size].
  Size? getPhoneSize() {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
  }

  /// Returns a notifier get updates about the app's layout mode.
  ///
  /// See also:
  /// * [DeviceStatusResponse].
  ValueNotifier<LayoutMode> getLayoutModeNotifier() {
    return _layoutMode;
  }

  /// Returns if mobile-only mode is currently forced.
  ///
  /// See also:
  /// * [Frame.wrapWithFrame]
  bool isMobileOnly() {
    return _mobileOnly;
  }

  /// Sets the mobile-only mode.
  void setMobileOnly(bool pMobileOnly) {
    _mobileOnly = pMobileOnly;
  }

  /// Returns if web-only mode is currently forced.
  ///
  /// See also:
  /// * [Frame.wrapWithFrame]
  bool isWebOnly() {
    return _webOnly;
  }

  /// Sets the web-only mode.
  void setWebOnly(bool pWebOnly) {
    _webOnly = pWebOnly;
  }

  /// Retrieves the current [ThemeMode] preference.
  ///
  /// Returns [ThemeMode.system] if none is configured.
  ThemeMode getThemePreference() {
    ThemeMode? themeMode;
    String? theme = getString("theme");
    if (theme != null) {
      themeMode = ThemeMode.values.firstWhereOrNull((e) => e.name == theme);
    }
    return themeMode ?? ThemeMode.system;
  }

  /// Sets the current [ThemeMode] preference.
  ///
  /// If [themeMode] is [ThemeMode.system], the preference will be set to `null`.
  Future<bool> setThemePreference(ThemeMode themeMode) {
    return setString("theme", themeMode == ThemeMode.system ? null : themeMode.name);
  }

  /// Retrieves the last known [ApplicationSettingsResponse].
  ApplicationSettingsResponse getApplicationSettings() {
    return _applicationSettings;
  }

  /// Sets the [ApplicationSettingsResponse].
  void setApplicationSettings(ApplicationSettingsResponse pApplicationSettings) {
    _applicationSettings = pApplicationSettings;
    // Trigger setState
    _callbacks['style']?.forEach((element) => element.call());
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _loadUserInfo() {
    if (_userInfo == null) {
      String? jsonMap = getString("userInfo");
      _userInfo = (jsonMap != null ? UserInfo.fromJson(pJson: jsonDecode(jsonMap)) : null);
    }
  }

  /// Initializes [_applicationStyle] by trying to retrieve it from offline storage.
  void _loadAppStyle() {
    if (_applicationStyle == null) {
      String? jsonMap = getString("applicationStyle");
      _applicationStyle = (jsonMap != null ? Map<String, String>.from(jsonDecode(jsonMap)) : null) ?? {};
    }
  }

  void _registerCallback(String type, Function pCallback) {
    _callbacks.putIfAbsent(type, () => []).add(pCallback);
  }

  void _disposeCallback(String type, Function pCallback) {
    _callbacks[type]?.remove(pCallback);
  }

  void _disposeCallbacks(String type) {
    _callbacks[type]?.clear();
  }

  void _loadLanguage(String pLanguage) {
    Translation langTrans = Translation.empty();

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

    _callbacks['language']?.forEach((element) => element.call(pLanguage));
  }
}
