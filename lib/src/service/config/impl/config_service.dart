import 'dart:io';

import 'package:flutter_client/src/model/config/user/user_info.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../i_config_service.dart';

/// Stores all config and session based data.
// Author: Michael Schober
class ConfigService implements IConfigService{

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the visionX app
  String appName;

  /// Url of the remote server
  String url;

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.url,
    required this.appName,
  });

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
  String getUrl() {
    return url;
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
  void setUrl(String pUrl) {
    url = pUrl;
  }

  @override
  void setVersion(String pVersion) {
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




}