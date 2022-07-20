import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../util/file/file_manager.dart';
import '../../../../util/logging/flutter_logger.dart';
import '../../../model/config/api/api_config.dart';
import '../../../model/config/translation/translation.dart';
import '../../../model/config/user/user_info.dart';
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

  /// Config of the api
  ApiConfig? apiConfig;

  String? appName;

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    this.appName,
    required this.fileManager,
    required this.sharedPrefs,
    List<Function>? pStyleCallbacks,
    List<Function>? pLanguageCallbacks,
  }) {
    if (pStyleCallbacks != null) {
      styleCallbacks.addAll(pStyleCallbacks);
    }
    if (pLanguageCallbacks != null) {
      languageCallbacks.addAll(pLanguageCallbacks);
    }

    fileManager.setAppName(pName: getAppName());
    String? version = getVersion();
    if (version != null) {
      fileManager.setAppVersion(pVersion: version);
      // Only load if version is set in FileManager
      reloadSupportedLanguages();
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation -- GETTER/SETTER
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    return sharedPrefs.getString("$appName.version");
  }

  @override
  setVersion(String? pVersion) {
    if (pVersion != null) {
      fileManager.setAppVersion(pVersion: pVersion);
      return sharedPrefs.setString("$appName.version", pVersion);
    } else {
      return sharedPrefs.remove("$appName.version");
    }
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
  String getAppName() {
    return (kDebugMode ? "demo" : sharedPrefs.getString("appName")) ?? "";
  }

  @override
  Future<bool> setAppName(String pAppName) {
    appName = pAppName;
    fileManager.setAppName(pName: pAppName);
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
    return sharedPrefs.getString("$appName.language") ?? "en";
  }

  @override
  Future<bool> setLanguage(String pLanguage) async {
    bool success = await sharedPrefs.setString("$appName.language", pLanguage);
    _loadLanguage(pLanguage);
    return success;
  }

  @override
  String? getAuthCode() {
    return sharedPrefs.getString("$appName.authKey");
  }

  @override
  Future<bool> setAuthCode(String? pAuthCode) {
    if (pAuthCode != null) {
      return sharedPrefs.setString("$appName.authKey", pAuthCode);
    } else {
      return sharedPrefs.remove("$appName.authKey");
    }
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
    log(pAppStyle.toString());

    if (pAppStyle == null) {
      applicationStyle.clear();
    } else {
      applicationStyle = pAppStyle;
    }

    styleCallbacks.forEach((element) => element.call(pAppStyle));
  }

  @override
  bool isOffline() {
    return sharedPrefs.getBool("$appName.offline") ?? false;
  }

  @override
  Future<bool> setOffline(bool pOffline) {
    return sharedPrefs.setBool("$appName.offline", pOffline);
  }

  @override
  String? getOfflineScreen() {
    return sharedPrefs.getString("$appName.offlineScreen");
  }

  @override
  Future<bool> setOfflineScreen(String pWorkscreen) {
    return sharedPrefs.setString("$appName.offlineScreen", pWorkscreen);
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
  ApiConfig? getApiConfig() {
    return apiConfig;
  }

  ///Only call if you know what you do!
  void setApiConfig(ApiConfig pApiConfig) {
    apiConfig = pApiConfig;
  }

  @override
  Map<String, dynamic> getStartUpParameters() {
    return startupParameters;
  }

  @override
  void addStartupParameter({required String pKey, required dynamic pValue}) {
    startupParameters[pKey] = pValue;
  }

  @override
  void disposeLanguageCallback({required Function(String language) pCallBack}) {
    languageCallbacks.remove(pCallBack);
  }

  @override
  void disposeStyleCallback({required Function(Map<String, String> style) pCallback}) {
    styleCallbacks.remove(pCallback);
  }

  @override
  void registerLanguageCallback({required Function(String language) pCallback}) {
    languageCallbacks.add(pCallback);
  }

  @override
  void registerStyleCallback({required Function(Map<String, String> style) pCallback}) {
    styleCallbacks.add(pCallback);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _loadLanguage(String pLanguage) {
    translation.translations.clear();
    File? defaultTranslationFile = fileManager.getFileSync(pPath: "languages/translation.json");
    File? langTransFile = fileManager.getFileSync(pPath: "languages/translation_$pLanguage.json");

    if (defaultTranslationFile != null) {
      Translation defaultTrans = Translation.fromFile(pFile: defaultTranslationFile);
      translation.translations.addAll(defaultTrans.translations);
    }

    if (langTransFile == null) {
      LOGGER.logW(pType: LOG_TYPE.CONFIG, pMessage: "Translation file for code $pLanguage could not be found");
    } else {
      Translation langTrans = Translation.fromFile(pFile: langTransFile);
      translation.translations.addAll(langTrans.translations);
    }

    languageCallbacks.forEach((element) => element.call(pLanguage));
  }
}
