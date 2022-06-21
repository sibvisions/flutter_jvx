import 'dart:io';

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

  /// Config of the api
  final ApiConfig apiConfig;

  /// Name of the visionX app
  String appName;

  /// Current clientId (sessionId)
  String? clientId;

  /// Version of the remote server
  late String version;

  /// Directory of the installed app, empty string if launched in web
  late String directory;

  /// Display options for menu
  MENU_MODE menuMode = MENU_MODE.GRID_GROUPED;

  /// Stores all info about current user
  UserInfo? userInfo;

  /// Parameters which will get added to every startup
  final Map<String, dynamic> startupParameters = {};

  /// Used to manage files, different implementations for web and mobile
  IFileManager fileManager;

  /// Display language will change display of all static text
  String langCode;

  Translation translation = Translation.empty();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.apiConfig,
    required this.appName,
    required this.fileManager,
    required this.langCode,
  }) {
    fileManager.setAppName(pName: appName);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String getAppName() {
    return appName;
  }

  @override
  String? getClientId() {
    return clientId;
  }

  @override
  String getVersion() {
    return version;
  }

  @override
  UserInfo? getUserInfo() {
    return userInfo;
  }

  @override
  void setAppName(String pAppName) {
    fileManager.setAppName(pName: pAppName);
    appName = pAppName;
  }

  @override
  void setClientId(String? pClientId) {
    clientId = pClientId;
  }

  @override
  void setVersion(String pVersion) {
    fileManager.setAppVersion(pVersion: pVersion);
    version = pVersion;
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
  void setUserInfo(UserInfo pUserInfo) {
    userInfo = pUserInfo;
  }

  @override
  ApiConfig getApiConfig() {
    return apiConfig;
  }

  @override
  void addStartupParameter({required String pKey, required dynamic pValue}) {
    startupParameters[pKey] = pValue;
  }

  @override
  Map<String, dynamic> getStartUpParameters() {
    return startupParameters;
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
    return langCode;
  }

  @override
  void setLanguage(String pLanguage) {
    langCode = pLanguage;

    File? defaultTranslationFile = fileManager.getFileSync(pPath: "translation.json");
    File? langTransFile = fileManager.getFileSync(pPath: "translation_$pLanguage.json");

    if (defaultTranslationFile != null) {
      Translation defaultTrans = Translation.fromFile(pFile: defaultTranslationFile);
      translation.translations.addAll(defaultTrans.translations);
    }

    if (langTransFile == null) {
      LOGGER.logW(pType: LOG_TYPE.CONFIG, pMessage: "Translation file for code $langCode could not be found");
    } else {
      Translation langTrans = Translation.fromFile(pFile: langTransFile);
      translation.translations.addAll(langTrans.translations);
    }
  }

  @override
  String translateText(String pText) {
    String? translatedText = translation.translations[pText];
    if (translatedText == null) {
      LOGGER.logD(pType: LOG_TYPE.CONFIG, pMessage: "Translation for text: $pText was not found for language $langCode");
      return pText;
    }
    return translatedText;
  }
}
