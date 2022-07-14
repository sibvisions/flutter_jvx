import '../../../util/file/file_manager.dart';
import '../../model/config/api/api_config.dart';
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
  ApiConfig getApiConfig();

  /// Return version
  String? getVersion();

  /// Set version
  Future<bool> setVersion(String? pVersion);

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

  /// Returns language code of current language
  String getLanguage();

  /// Set current display language, app will need to restart to take effect (new Startup)
  Future<bool> setLanguage(String pLanguage);

  /// Translates text in current translation, will return the original text if not translation was found
  String translateText(String pText);

  /// Set auth code for future auto-login
  Future<bool> setAuthCode(String? pAuthCode);

  /// Get auth code if one has been set
  String? getAuthCode();

  /// Returns a modifiable list of all supported languages codes
  Set<String> getSupportedLanguages();

  void reloadSupportedLanguages();

  /// Get app style sent from server
  Map<String, String>? getAppStyle();

  /// Set app style, usually only called after download
  void setAppStyle(Map<String, String>? pAppStyle);

  /// Callback will be called when style has been set
  void registerStyleCallback({required Function(Map<String, String> style) pCallback});

  /// Removes the callback
  void disposeStyleCallback({required Function(Map<String, String> style) pCallback});

  /// Callback will be called when language has been set
  void registerLanguageCallback({required Function(String language) pCallback});

  /// Removes the callback
  void disposeLanguageCallback({required Function(String language) pCallBack});
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
