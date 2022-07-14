import 'dart:developer';
import 'dart:io';

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

  /// Config of the api
  final ApiConfig apiConfig;

  /// Parameters which will get added to every startup
  final Map<String, dynamic> startupParameters = {};

  /// List of all active styleCallbacks
  final List<Function> styleCallbacks = [];

  /// List of all active languageStyleCallbacks
  final List<Function> languageCallbacks = [];

  String appName;

  /// Current clientId (sessionId)
  String? clientId;

  /// Display options for menu
  MENU_MODE menuMode = MENU_MODE.GRID_GROUPED;

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
    required this.appName,
    required this.apiConfig,
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

    fileManager.setAppName(pName: appName);
    var success = _loadVersion();

    // Only load if version is set in FileManager
    if (success) {
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
  void setVersion(String? pVersion) async {
    if (pVersion != null) {
      fileManager.setAppVersion(pVersion: pVersion);
      await sharedPrefs.setString("$appName.version", pVersion);
    } else {
      await sharedPrefs.remove("$appName.version");
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
    return appName;
  }

  @override
  void setAppName(String pAppName) async {
    appName = pAppName;
    fileManager.setAppName(pName: pAppName);
    await sharedPrefs.setString(appName, pAppName);
  }

  @override
  MENU_MODE getMenuMode() {
    return menuMode;
  }

  @override
  void setMenuMode(MENU_MODE pMenuMode) {
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
  void setLanguage(String pLanguage) async {
    await sharedPrefs.setString("$appName.language", pLanguage);
    _loadLanguage(pLanguage);
  }

  @override
  String? getAuthCode() {
    return sharedPrefs.getString("$appName.authKey");
  }

  @override
  void setAuthCode(String? pAuthCode) async {
    if (pAuthCode != null) {
      await sharedPrefs.setString("$appName.authKey", pAuthCode);
    } else {
      await sharedPrefs.remove("$appName.authKey");
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
  ApiConfig getApiConfig() {
    return apiConfig;
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

  // Returns [bool] if version was loaded successfully
  bool _loadVersion() {
    // Load version
    if (sharedPrefs.containsKey("$appName.version")) {
      var version = sharedPrefs.getString("$appName.version");
      // Set app version so version specific files can be get
      fileManager.setAppVersion(pVersion: version);
      return true;
    }
    return false;
  }

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
