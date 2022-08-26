import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/app_config.dart';
import '../../../../config/server_config.dart';
import '../../../../util/logging/flutter_logger.dart';
import '../../../mask/menu/menu_mode.dart';
import '../../../model/config/translation/translation.dart';
import '../../../model/config/user/user_info.dart';
import '../../../model/response/application_meta_data_response.dart';
import '../../../util/config_util.dart';
import '../../file/file_manager.dart';
import '../i_config_service.dart';

/// Stores all config and session based data.
class ConfigService implements IConfigService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Set<String> supportedLanguages = {"en"};

  final SharedPreferences sharedPrefs;

  /// Parameters which will get added to every startup
  final Map<String, dynamic> startupParameters = {};

  /// Map of all active callbacks
  final Map<String, List<Function>> callbacks = {};

  /// If the style callbacks are active
  bool activeStyleCallbacks = true;

  /// If the language callbacks are active
  bool activeLanguageCallbacks = true;

  /// Config of the app
  AppConfig? appConfig;

  /// Metadata of the app
  ApplicationMetaDataResponse? metaData;

  /// Current clientId (sessionId)
  String? clientId;

  /// Stores all info about current user
  UserInfo? userInfo;

  /// Used to manage files, different implementations for web and mobile
  IFileManager fileManager;

  /// Current translation, base translation + overlaid language
  Translation translation = Translation.empty();

  /// Application style sent from server
  Map<String, String>? applicationStyle;

  /// The phone size
  Size? phoneSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.fileManager,
    required this.sharedPrefs,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation -- GETTER/SETTER
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  SharedPreferences getSharedPreferences() {
    return sharedPrefs;
  }

  @override
  String? getClientId() {
    //TODO remove workaround
    return clientId ?? (isOffline() ? "" : null);
  }

  @override
  void setClientId(String? pClientId) {
    clientId = pClientId;
  }

  @override
  ApplicationMetaDataResponse? getMetaData() {
    return metaData;
  }

  @override
  void setMetaData(ApplicationMetaDataResponse? pMetaData) {
    metaData = pMetaData;
  }

  @override
  String? getVersion() {
    return getString("version");
  }

  @override
  setVersion(String? pVersion) {
    return setString("version", pVersion);
  }

  @override
  UserInfo? getUserInfo() {
    _loadUserInfo();
    return userInfo;
  }

  @override
  Future<bool> setUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson}) async {
    userInfo = pUserInfo;
    return setString("userInfo", pJson != null ? jsonEncode(pJson) : null);
  }

  void _loadUserInfo() {
    if (userInfo == null) {
      String? jsonMap = getString("userInfo");
      userInfo = (jsonMap != null ? UserInfo.fromJson(pJson: jsonDecode(jsonMap)) : null);
    }
  }

  @override
  String? getAppName() {
    return sharedPrefs.getString("appName") ?? getAppConfig()?.serverConfig.appName;
  }

  @override
  Future<bool> setAppName(String pAppName) {
    return sharedPrefs.setString("appName", pAppName);
  }

  @override
  MenuMode getMenuMode() {
    return ConfigUtil.getMenuMode(getAppStyle()["menu.mode"]);
  }

  @override
  IFileManager getFileManager() {
    return fileManager;
  }

  @override
  void setFileManger(IFileManager pFileManger) {
    fileManager = pFileManger;
  }

  @override
  String getLanguage() {
    return getString("language") ?? _getPlatformLocale();
  }

  @override
  Future<bool> setLanguage(String? pLanguage) async {
    bool success = await setString("language", pLanguage == _getPlatformLocale() ? null : pLanguage);
    loadLanguages();
    return success;
  }

  String _getPlatformLocale() {
    return Platform.localeName.substring(0, Platform.localeName.indexOf("_"));
  }

  @override
  void loadLanguages() {
    _loadLanguage(getLanguage());
  }

  @override
  String? getBaseUrl() {
    return getString("baseUrl") ?? getAppConfig()?.serverConfig.baseUrl;
  }

  @override
  Future<bool> setBaseUrl(String? baseUrl) {
    return setString("baseUrl", baseUrl);
  }

  @override
  String? getUsername() {
    return getString("username") ?? getAppConfig()?.serverConfig.username;
  }

  @override
  Future<bool> setUsername(String? username) {
    return setString("username", username);
  }

  @override
  String? getPassword() {
    return getString("password") ?? getAppConfig()?.serverConfig.password;
  }

  @override
  Future<bool> setPassword(String? password) {
    return setString("password", password);
  }

  @override
  String? getAuthCode() {
    return getString("authKey");
  }

  @override
  Future<bool> setAuthCode(String? pAuthCode) {
    return setString("authKey", pAuthCode);
  }

  @override
  Set<String> getSupportedLanguages() {
    return supportedLanguages;
  }

  @override
  void reloadSupportedLanguages() {
    // Add supported languages by parsing all translation file names
    Directory? langDir = fileManager.getDirectory(pPath: "${IFileManager.LANGUAGES_PATH}/");
    if (langDir != null && langDir.existsSync()) {
      List<String> fileNames = langDir.listSync().map((e) => e.path.split("/").last).toList();

      fileNames.forEach((element) {
        RegExpMatch? match = IConfigService.langRegex.firstMatch(element);
        if (match != null) {
          supportedLanguages.add(match.namedGroup("name")!);
        }
      });
    }
  }

  @override
  Map<String, String> getAppStyle() {
    _loadAppStyle();
    return applicationStyle!;
  }

  @override
  Future<bool> setAppStyle(Map<String, String>? pAppStyle) {
    log("AppStyle: $pAppStyle");

    if (pAppStyle == null) {
      applicationStyle?.clear();
    } else {
      applicationStyle = pAppStyle;
    }

    if (activeStyleCallbacks) {
      callbacks['style']?.forEach((element) => element.call(pAppStyle));
    }
    return setString("applicationStyle", pAppStyle != null ? jsonEncode(pAppStyle) : null);
  }

  @override
  double getOpacityMenu() {
    _loadAppStyle();
    return double.parse(applicationStyle!['opacity.menu'] ?? '1');
  }

  @override
  double getOpacitySideMenu() {
    _loadAppStyle();
    return double.parse(applicationStyle!['opacity.sidemenu'] ?? '1');
  }

  @override
  double getOpacityControls() {
    _loadAppStyle();
    return double.parse(applicationStyle!['opacity.controls'] ?? '1');
  }

  void _loadAppStyle() {
    if (applicationStyle == null) {
      String? jsonMap = getString("applicationStyle");
      applicationStyle = (jsonMap != null ? Map<String, String>.from(jsonDecode(jsonMap)) : null) ?? {};
    }
  }

  @override
  int? getPictureResolution() {
    return sharedPrefs.getInt("$getAppName.pictureSize");
  }

  @override
  Future<bool> setPictureResolution(int pictureResolution) {
    return sharedPrefs.setInt("$getAppName.pictureSize", pictureResolution);
  }

  @override
  bool isOffline() {
    return sharedPrefs.getBool("$getAppName.offline") ?? false;
  }

  @override
  Future<bool> setOffline(bool pOffline) {
    return sharedPrefs.setBool("$getAppName.offline", pOffline);
  }

  @override
  String? getOfflineScreen() {
    return getString("offlineScreen");
  }

  @override
  Future<bool> setOfflineScreen(String pWorkscreen) {
    return setString("offlineScreen", pWorkscreen);
  }

  @override
  String? getString(String key) {
    return sharedPrefs.getString("${getAppName()}.$key");
  }

  @override
  Future<bool> setString(String key, String? value) {
    if (value != null) {
      return sharedPrefs.setString("${getAppName()}.$key", value);
    } else {
      return sharedPrefs.remove("${getAppName()}.$key");
    }
  }

  // ------------------------------

  @override
  String translateText(String pText) {
    String? translatedText = translation.translations[pText];
    if (translatedText == null) {
      LOGGER.logD(
          pType: LogType.CONFIG, pMessage: "Translation for text: $pText was not found for language ${getLanguage()}");
      return pText;
    }
    return translatedText;
  }

  @override
  AppConfig? getAppConfig() {
    return appConfig;
  }

  ///Only call if you know what you do!
  setAppConfig(AppConfig? pAppConfig, [bool devConfig = false]) async {
    appConfig = pAppConfig;
    if (devConfig) {
      if (pAppConfig?.serverConfig.appName != null) {
        await setAppName(pAppConfig!.serverConfig.appName!);
      }
      if (pAppConfig?.serverConfig.baseUrl != null) {
        await setBaseUrl(pAppConfig!.serverConfig.baseUrl!);
      }
      if (pAppConfig?.serverConfig.username != null) {
        await setUsername(pAppConfig!.serverConfig.username!);
      }
      if (pAppConfig?.serverConfig.password != null) {
        await setPassword(pAppConfig!.serverConfig.password!);
      }
    }
  }

  @override
  ServerConfig getServerConfig() {
    return ServerConfig(
      baseUrl: getBaseUrl(),
      appName: getAppName(),
      username: getUsername(),
      password: getPassword(),
    );
  }

  @override
  Map<String, dynamic> getStartupParameters() {
    return startupParameters;
  }

  @override
  void setStartupParameter({required String pKey, required dynamic pValue}) {
    startupParameters[pKey] = pValue;
  }

  @override
  void registerLanguageCallback(Function(String language) pCallback) {
    registerCallback("language", pCallback);
  }

  @override
  void disposeLanguageCallback(Function(String language) pCallback) {
    disposeCallback("language", pCallback);
  }

  @override
  void disposeLanguageCallbacks() {
    disposeCallbacks("language");
  }

  @override
  void pauseLanguageCallbacks() {
    activeLanguageCallbacks = false;
  }

  @override
  void resumeLanguageCallbacks() {
    activeLanguageCallbacks = true;
  }

  @override
  void registerStyleCallback(Function(Map<String, String> style) pCallback) {
    registerCallback("style", pCallback);
  }

  @override
  void disposeStyleCallback(Function(Map<String, String> style) pCallback) {
    disposeCallback("style", pCallback);
  }

  @override
  void disposeStyleCallbacks() {
    disposeCallbacks("style");
  }

  @override
  void pauseStyleCallbacks() {
    activeStyleCallbacks = false;
  }

  @override
  void resumeStyleCallbacks() {
    activeStyleCallbacks = true;
  }

  @override
  void registerImagesCallback(Function() pCallback) {
    registerCallback("images", pCallback);
  }

  @override
  void disposeImagesCallback(Function() pCallback) {
    disposeCallback("images", pCallback);
  }

  @override
  void disposeImagesCallbacks() {
    disposeCallbacks("images");
  }

  @override
  void imagesChanged() {
    callbacks["images"]?.forEach((element) => element.call());
  }

  @override
  Size? getPhoneSize() {
    return phoneSize;
  }

  @override
  void setPhoneSize(Size? pPhoneSize) {
    phoneSize = pPhoneSize;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void registerCallback(String type, Function pCallback) {
    callbacks.putIfAbsent(type, () => []).add(pCallback);
  }

  void disposeCallback(String type, Function pCallback) {
    callbacks[type]?.remove(pCallback);
  }

  void disposeCallbacks(String type) {
    callbacks[type]?.clear();
  }

  void _loadLanguage(String pLanguage) {
    Translation langTrans = Translation.empty();

    File? langTransFile = fileManager.getFileSync(pPath: "${IFileManager.LANGUAGES_PATH}/translation_$pLanguage.json");
    if (langTransFile == null) {
      LOGGER.logW(pType: LogType.CONFIG, pMessage: "Translation file for code $pLanguage could not be found");
    } else {
      langTrans.merge(langTransFile);
    }

    langTransFile = fileManager.getFileSync(pPath: "${IFileManager.LANGUAGES_PATH}/translation.json");
    langTrans.merge(langTransFile);

    translation = langTrans;

    if (activeLanguageCallbacks) {
      callbacks["language"]?.forEach((element) => element.call(pLanguage));
    }
  }
}
