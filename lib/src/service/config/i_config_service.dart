import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';
import '../../mask/menu/menu_mode.dart';
import '../../model/config/user/user_info.dart';
import '../../model/response/application_meta_data_response.dart';
import '../../model/response/device_status_response.dart';
import '../file/file_manager.dart';
import '../service.dart';

/// Defines the base construct of a [IConfigService]
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
abstract class IConfigService {
  static final RegExp langRegex = RegExp("_(?<name>[a-z]+)");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IConfigService() => services<IConfigService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SharedPreferences getSharedPreferences();

  /// Returns current clientId, if none is present returns null
  String? getClientId();

  /// Set clientId
  void setClientId(String? pClientId);

  ApplicationMetaDataResponse? getMetaData();

  void setMetaData(ApplicationMetaDataResponse? metaData);

  /// Returns the appName
  String? getAppName();

  /// Set appName
  Future<bool> setAppName(String? pAppName);

  /// Returns initial final appConfig
  AppConfig? getAppConfig();

  /// Return version
  String? getVersion();

  /// Set version
  Future<bool> setVersion(String? pVersion);

  /// Return menuMode
  MenuMode getMenuMode();

  /// Returns info about the current user
  UserInfo? getUserInfo();

  /// Set user info
  Future<bool> setUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson});

  /// Returns a map of all added parameters which should be added on every startup
  Map<String, dynamic> getStartupParameters();

  /// Add a parameter that will get send in the next startup
  void setStartupParameter({required String pKey, required dynamic pValue});

  /// Returns instance of [IFileManager]
  IFileManager getFileManager();

  /// Set instance of [IFileManager]
  void setFileManger(IFileManager pFileManger);

  /// Returns language code of current language
  String getLanguage();

  /// Set current display language
  Future<bool> setLanguage(String? pLanguage);

  /// Reload current language (after translation files update)
  void loadLanguages();

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
  Map<String, String> getAppStyle();

  /// Set app style, usually only called after download
  Future<bool> setAppStyle(Map<String, String>? pAppStyle);

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

  /// Gets the layoutMode from the server
  ValueNotifier<LayoutMode> getLayoutMode();

  bool isMobileOnly();

  Future<bool> setMobileOnly(bool pMobileOnly);

  bool isWebOnly();

  Future<bool> setWebOnly(bool pWebOnly);

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

  /// Callback will be called when language has been set
  void registerLanguageCallback(Function(String language) pCallback);

  /// Removes the callback
  void disposeLanguageCallback(Function(String language) pCallback);

  /// Removes all language callbacks
  void disposeLanguageCallbacks();

  void imagesChanged();

  /// Callback will be called when language has been set
  void registerImagesCallback(Function() pCallback);

  /// Removes the callback
  void disposeImagesCallback(Function() pCallback);

  /// Removes all language callbacks
  void disposeImagesCallbacks();
}
