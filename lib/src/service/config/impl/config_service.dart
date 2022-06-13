import 'package:flutter_client/src/model/config/api/api_config.dart';
import 'package:flutter_client/src/model/config/user/user_info.dart';
import 'package:flutter_client/util/file/file_manager.dart';

import '../i_config_service.dart';

/// Stores all config and session based data.
// Author: Michael Schober
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.apiConfig,
    required this.appName,
    required this.fileManager,
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
  String getDirectory() {
    return directory;
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
  void setDirectory(String pDirectory) {
    directory = pDirectory;
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
}
