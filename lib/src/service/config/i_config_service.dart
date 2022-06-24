import 'package:flutter_client/src/model/config/api/api_config.dart';
import 'package:flutter_client/src/model/config/user/user_info.dart';

import '../../../util/file/file_manager.dart';

/// Defines the base construct of a [IConfigService]
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
// Author: Michael Schober
abstract class IConfigService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns current clientId, if none is present returns null
  String? getClientId();

  /// Set clientId
  void setClientId(String? pClientId);

  /// Returns the appName
  String getAppName();

  /// Set appName
  void setAppName(String pAppName);

  /// Returns current apiConfig
  ApiConfig getApiConfig();

  /// Set version
  void setVersion(String? pVersion);

  /// Return version
  String? getVersion();

  /// Return menuMode
  MENU_MODE getMenuMode();

  /// Set MenuMode
  void setMenuMode(MENU_MODE pMenuMode);

  /// Returns info about the current user
  UserInfo? getUserInfo();

  /// Set user inf
  void setUserInfo(UserInfo? pUserInfo);

  /// Returns a map of all added parameters which should be added on every startup
  Map<String, dynamic> getStartUpParameters();

  /// Add a parameter that will get send in the next startup
  void addStartupParameter({required String pKey, required dynamic pValue});

  /// Returns instance of [IFileManager]
  IFileManager getFileManager();

  /// Set instance of [IFileManager]
  void setFileManger(IFileManager pFileManger);

  /// Set current display language
  void setLanguage(String pLangCode);

  /// Returns language code of current language
  String getLanguage();

  /// Translates text in current translation, will return the original text if not translation was found
  String translateText(String pText);

  /// Set auth code for future auto-login
  void setAuthCode(String? pAuthCode);

  /// Get auth code if one has been set
  String? getAuthCode();

  /// Return a list of all supported languages codes
  List<String> getSupportedLang();

  /// Return a list of all supported languages codes
  void setSupportedLang({required List<String> languages});

  /// Get app style sent from server
  Map<String, String>? getAppStyle();

  /// Set app style, usually only called after download
  void setAppStyle(Map<String, String>? pAppStyle);
}

enum MENU_MODE {
  GRID,
  GRID_GROUPED,
  LIST,
  LIST_GROUPED,
  DRAWER,
  SWIPER,
  TABS,
}
