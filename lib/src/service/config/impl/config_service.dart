import 'dart:developer';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/app_config.dart';
import '../../../../config/server_config.dart';
import '../../../../util/logging/flutter_logger.dart';
import '../../../model/config/translation/translation.dart';
import '../../../model/config/user/user_info.dart';
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

  /// List of all active styleCallbacks
  final List<Function> styleCallbacks = [];

  /// List of all active languageStyleCallbacks
  final List<Function> languageCallbacks = [];

  /// If the style callbacks are active
  bool activeStyleCallbacks = true;

  /// If the language callbacks are active
  bool activeLanguageCallbacks = true;

  /// Config of the app
  AppConfig? appConfig;

  /// Current clientId (sessionId)
  String? clientId;

  /// Display options for menu
  MenuMode menuMode = MenuMode.GRID_GROUPED;

  /// Stores all info about current user
  UserInfo? userInfo;

  /// Used to manage files, different implementations for web and mobile
  IFileManager fileManager;

  /// Current translation, base translation + overlaid language
  Translation translation = Translation.empty();

  /// Application style sent from server
  Map<String, String> applicationStyle = {};

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
    return clientId;
  }

  @override
  void setClientId(String? pClientId) {
    clientId = pClientId;
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
    return userInfo;
  }

  @override
  void setUserInfo(UserInfo? pUserInfo) {
    userInfo = pUserInfo;
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
    return menuMode;
  }

  @override
  void setMenuMode(MenuMode pMenuMode) {
    menuMode = pMenuMode;
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
    return getString("language") ?? "en";
  }

  @override
  Future<bool> setLanguage(String pLanguage) async {
    bool success = await setString("language", pLanguage);
    _loadLanguage(pLanguage);
    return success;
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
    Directory? langDir = fileManager.getDirectory(pPath: "languages/");
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
    return applicationStyle;
  }

  @override
  void setAppStyle(Map<String, String>? pAppStyle) {
    log("AppStyle: " + pAppStyle.toString());

    if (pAppStyle == null) {
      applicationStyle.clear();
    } else {
      applicationStyle = pAppStyle;
    }

    if (activeStyleCallbacks) {
      styleCallbacks.forEach((element) => element.call(pAppStyle));
    }
  }

  @override
  double getOpacityMenu() {
    return double.parse(applicationStyle['opacity.menu'] ?? '1');
  }

  @override
  double getOpacitySideMenu() {
    return double.parse(applicationStyle['opacity.sidemenu'] ?? '1');
  }

  @override
  double getOpacityControls() {
    return double.parse(applicationStyle['opacity.controls'] ?? '1');
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
    return sharedPrefs.getString("$getAppName.$key");
  }

  @override
  Future<bool> setString(String key, String? value) {
    if (value != null) {
      return sharedPrefs.setString("$getAppName.$key", value);
    } else {
      return sharedPrefs.remove("$getAppName.$key");
    }
  }

  // ------------------------------

  @override
  String translateText(String pText) {
    String? translatedText = translation.translations[pText];
    if (translatedText == null) {
      LOGGER.logD(
          pType: LOG_TYPE.CONFIG, pMessage: "Translation for text: $pText was not found for language ${getLanguage()}");
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
    languageCallbacks.add(pCallback);
  }

  @override
  void disposeLanguageCallback(Function(String language) pCallBack) {
    languageCallbacks.remove(pCallBack);
  }

  @override
  void disposeLanguageCallbacks() {
    languageCallbacks.clear();
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
    styleCallbacks.add(pCallback);
  }

  @override
  void disposeStyleCallback(Function(Map<String, String> style) pCallback) {
    styleCallbacks.remove(pCallback);
  }

  @override
  void disposeStyleCallbacks() {
    styleCallbacks.clear();
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

  void _loadLanguage(String pLanguage) {
    translation.translations.clear();

    File? langTransFile;
    if (pLanguage == "en") {
      langTransFile = fileManager.getFileSync(pPath: "languages/translation.json");
    } else {
      // Not sure if english should be loaded all the time
      // File? defaultTranslationFile = fileManager.getFileSync(pPath: "languages/translation.json");
      // if (defaultTranslationFile != null) {
      //   Translation defaultTrans = Translation.fromFile(pFile: defaultTranslationFile);
      //   translation.translations.addAll(defaultTrans.translations);
      // }

      langTransFile = fileManager.getFileSync(pPath: "languages/translation_$pLanguage.json");
    }

    if (langTransFile == null) {
      LOGGER.logW(pType: LOG_TYPE.CONFIG, pMessage: "Translation file for code $pLanguage could not be found");
    } else {
      Translation langTrans = Translation.fromFile(pFile: langTransFile);
      translation.translations.addAll(langTrans.translations);
    }

    if (activeLanguageCallbacks) {
      languageCallbacks.forEach((element) => element.call(pLanguage));
    }
  }
}
