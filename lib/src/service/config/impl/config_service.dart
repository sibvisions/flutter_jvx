import 'dart:convert';
import 'dart:io';

import 'package:flutter_client/src/model/config/config_file/last_run_config.dart';
import 'package:flutter_client/src/model/config/translation/translation.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';

import '../../../../util/file/file_manager.dart';
import '../../../model/config/api/api_config.dart';
import '../../../model/config/user/user_info.dart';
import '../i_config_service.dart';

/// Stores all config and session based data.
class ConfigService implements IConfigService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  List<String> supportedLanguages;

  final LastRunConfig lastRunConfig = LastRunConfig();

  /// Config of the api
  final ApiConfig apiConfig;

  /// Parameters which will get added to every startup
  final Map<String, dynamic> startupParameters = {};

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.appName,
    required this.apiConfig,
    required this.fileManager,
    required this.supportedLanguages,
    required String langCode,
  }) {
    fileManager.setAppName(pName: appName);
    lastRunConfig.language = langCode;
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
    return lastRunConfig.version;
  }

  @override
  void setVersion(String? pVersion) {
    if (pVersion != null) {
      fileManager.setAppVersion(pVersion: pVersion);
    }
    lastRunConfig.version = pVersion;
    _saveRunConfigToFile();
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
  void setAppName(String pAppName) {
    appName = pAppName;
    fileManager.setAppName(pName: pAppName);
    _saveRunConfigToFile();
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
    return lastRunConfig.language!;
  }

  @override
  void setLanguage(String pLanguage) {
    lastRunConfig.language = pLanguage;
    _saveRunConfigToFile();

    File? defaultTranslationFile = fileManager.getFileSync(pPath: "languages/translation.json");
    File? langTransFile = fileManager.getFileSync(pPath: "languages/translation_$pLanguage.json");

    if (defaultTranslationFile != null) {
      Translation defaultTrans = Translation.fromFile(pFile: defaultTranslationFile);
      translation.translations.addAll(defaultTrans.translations);
    }

    if (langTransFile == null) {
      LOGGER.logW(pType: LOG_TYPE.CONFIG, pMessage: "Translation file for code ${lastRunConfig.language} could not be found");
    } else {
      Translation langTrans = Translation.fromFile(pFile: langTransFile);
      translation.translations.addAll(langTrans.translations);
    }
  }

  @override
  String? getAuthCode() {
    return lastRunConfig.authCode;
  }

  @override
  void setAuthCode(String? pAuthCode) {
    lastRunConfig.authCode = pAuthCode;
    _saveRunConfigToFile();
  }

  @override
  List<String> getSupportedLang() {
    return supportedLanguages;
  }

  @override
  void setSupportedLang({required List<String> languages}) {
    supportedLanguages = languages;
  }

  // ------------------------------

  @override
  String translateText(String pText) {
    String? translatedText = translation.translations[pText];
    if (translatedText == null) {
      LOGGER.logD(pType: LOG_TYPE.CONFIG, pMessage: "Translation for text: $pText was not found for language ${lastRunConfig.language}");
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _saveRunConfigToFile() {
    fileManager.saveIndependentFile(pContent: jsonEncode(lastRunConfig).runes.toList(), pPath: "$appName/lastRunConfig.json");
  }
}
