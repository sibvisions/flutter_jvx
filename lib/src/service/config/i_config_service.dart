import 'package:flutter/cupertino.dart';

import '../../../util/file/file_manager.dart';
import '../../model/config/config_file/app_config.dart';
import '../../model/config/config_file/server_config.dart';
import '../../model/config/user/user_info.dart';

/// Defines the base construct of a [IConfigService]
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
// Author: Michael Schober
abstract class IConfigService {
  static final RegExp langRegex = RegExp("_(?<name>[a-z]+)");

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
  Future<bool> setAppName(String pAppName);

  /// Returns current apiConfig
  AppConfig? getAppConfig();

  ServerConfig? getServerConfig();

  /// Return version
  String? getVersion();

  /// Set version
  Future<bool> setVersion(String? pVersion);

  /// Return menuMode
  MenuMode getMenuMode();

  /// Set MenuMode
  void setMenuMode(MenuMode pMenuMode);

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

  /// Returns language code of current language
  String getLanguage();

  /// Set current display language, app will need to restart to take effect (new Startup)
  Future<bool> setLanguage(String pLanguage);

  /// Translates text in current translation, will return the original text if not translation was found
  String translateText(String pText);

  /// Gets the saved base url
  String? getBaseUrl();

  /// Gets the saved base url
  Future<bool> setBaseUrl(String? baseUrl);

  /// Gets the last used username
  String? getUsername();

  /// Sets the last used username
  Future<bool> setUsername(String? username);

  /// Gets the last used password
  String? getPassword();

  /// Sets the last used password
  Future<bool> setPassword(String? password);

  /// Get auth code if one has been set
  String? getAuthCode();

  /// Set auth code for future auto-login
  Future<bool> setAuthCode(String? pAuthCode);

  /// Returns a modifiable list of all supported languages codes
  Set<String> getSupportedLanguages();

  void reloadSupportedLanguages();

  /// Get app style sent from server
  Map<String, String>? getAppStyle();

  /// Set app style, usually only called after download
  void setAppStyle(Map<String, String>? pAppStyle);

  /// Mobile Style Properties
  double getOpacityMenu();

  /// Mobile Style Properties
  double getOpacitySideMenu();

  /// Mobile Style Properties
  double getOpacityControls();

  /// Get configured picture resolution
  int? getPictureResolution();

  /// Set picture resolution
  Future<bool> setPictureResolution(int pictureResolution);

  bool isOffline();

  Future<bool> setOffline(bool pOffline);

  /// Gets the last screen before going offline
  String? getOfflineScreen();

  /// Sets the last screen before going offline
  Future<bool> setOfflineScreen(String pWorkscreen);

  /// Gets the phone size for the startup command
  Size? getPhoneSize();

  /// Sets the phone size for the startup command
  void setPhoneSize(Size? pPhoneSize);

  /// Get a general app setting
  String? getString(String key);

  /// Set a general app setting
  Future<bool> setString(String key, String? value);

  /// Callback will be called when style has been set
  void registerStyleCallback(Function(Map<String, String> style) pCallback);

  /// Removes the callback
  void disposeStyleCallback(Function(Map<String, String> style) pCallback);

  /// Removes all style callbacks
  void disposeStyleCallbacks();

  /// Pauses all style callbacks.
  void pauseStyleCallbacks();

  /// Resumes all style callbacks.
  void resumeStyleCallbacks();

  /// Callback will be called when language has been set
  void registerLanguageCallback(Function(String language) pCallback);

  /// Removes the callback
  void disposeLanguageCallback(Function(String language) pCallBack);

  /// Removes all language callbacks
  void disposeLanguageCallbacks();

  /// Pauses all language callbacks.
  void pauseLanguageCallbacks();

  /// Resumes all language callbacks.
  void resumeLanguageCallbacks();
}

enum MenuMode {
  GRID,
  GRID_GROUPED,
  LIST,
  LIST_GROUPED,
  DRAWER,
  SWIPER,
  TABS,
}
