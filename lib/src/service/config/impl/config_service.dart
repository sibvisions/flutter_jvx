import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/app_config.dart';
import '../../../../flutter_jvx.dart';
import '../../../mask/menu/menu.dart';
import '../../../model/config/translation/translation.dart';
import '../../../model/config/user/user_info.dart';
import '../../../model/response/application_meta_data_response.dart';
import '../../../model/response/application_settings_response.dart';
import '../../../model/response/device_status_response.dart';
import '../../../util/config_util.dart';
import '../../file/file_manager.dart';
import '../i_config_service.dart';

/// Stores all config and session based data.
class ConfigService implements IConfigService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Set<String> supportedLanguages = {};

  final SharedPreferences sharedPrefs;

  /// Parameters which will get added to every startup
  final Map<String, dynamic> startupParameters = {};

  /// Map of all active callbacks
  final Map<String, List<Function>> callbacks = {};

  /// Config of the app
  AppConfig? appConfig;

  /// Metadata of the app
  ApplicationMetaDataResponse? metaData;

  /// Current clientId (sessionId)
  String? clientId;

  /// Stores all info about current user
  UserInfo? userInfo;

  /// Used to manage files, different implementations for web and mobile
  IFileManager fileManager;

  /// Current display language
  String? language;

  /// Current translation, base translation + overlaid language
  Translation translation = Translation.empty();

  /// Application style sent from server
  Map<String, String>? applicationStyle;

  /// JVx Application Settings
  ApplicationSettingsResponse applicationSettings = ApplicationSettingsResponse.empty();

  /// The phone size
  Size? phoneSize;

  /// The last layoutMode from the server
  ValueNotifier<LayoutMode> layoutMode = ValueNotifier(kIsWeb ? LayoutMode.Full : LayoutMode.Mini);

  /// The current offline state
  ValueNotifier<bool>? offlineNotifier;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.fileManager,
    required this.sharedPrefs,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation -- GETTER/SETTER
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  SharedPreferences getSharedPreferences() {
    return sharedPrefs;
  }

  @override
  String? getClientId() {
    return clientId;
  }

  @override
  void setClientId(String? pClientId) {
    clientId = pClientId;
  }

  @override
  ApplicationMetaDataResponse? getMetaData() {
    return metaData;
  }

  @override
  void setMetaData(ApplicationMetaDataResponse? pMetaData) {
    metaData = pMetaData;
  }

  @override
  String? getVersion() {
    return getString("version");
  }

  @override
  setVersion(String? pVersion) {
    return setString("version", pVersion);
  }

  @override
  UserInfo? getUserInfo() {
    _loadUserInfo();
    return userInfo;
  }

  @override
  Future<bool> setUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson}) async {
    userInfo = pUserInfo;
    return setString("userInfo", pJson != null ? jsonEncode(pJson) : null);
  }

  void _loadUserInfo() {
    if (userInfo == null) {
      String? jsonMap = getString("userInfo");
      userInfo = (jsonMap != null ? UserInfo.fromJson(pJson: jsonDecode(jsonMap)) : null);
    }
  }

  @override
  String? getAppName() {
    return sharedPrefs.getString("appName") ?? getAppConfig()?.serverConfig!.appName;
  }

  @override
  Future<bool> setAppName(String? pAppName) {
    if (pAppName == null) return sharedPrefs.remove("appName");
    return sharedPrefs.setString("appName", pAppName);
  }

  @override
  MenuMode getMenuMode() {
    return ConfigUtil.getMenuMode(getAppStyle()['menu.mode']);
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
  String getDisplayLanguage() {
    return getLanguage() ?? getUserLanguage() ?? IConfigService.getPlatformLocale();
  }

  @override
  String? getLanguage() {
    return language;
  }

  @override
  void setLanguage(String? pLanguage) {
    language = pLanguage;
    if (fileManager.isSatisfied()) {
      loadLanguages();
    }
  }

  @override
  String? getUserLanguage() {
    return getString("language");
  }

  @override
  Future<bool> setUserLanguage(String? pLanguage) async {
    bool success = await setString("language", pLanguage);
    if (fileManager.isSatisfied()) {
      loadLanguages();
    }
    return success;
  }

  @override
  void loadLanguages() {
    _loadLanguage(getDisplayLanguage());
  }

  @override
  Set<String> getSupportedLanguages() {
    return supportedLanguages;
  }

  @override
  void reloadSupportedLanguages() {
    // Add supported languages by parsing all translation file names
    supportedLanguages.clear();

    List<File> listFiles = fileManager.getTranslationFiles();

    for (File file in listFiles) {
      String fileName = file.path.split("/").last;
      RegExpMatch? match = IConfigService.langRegex.firstMatch(fileName);
      if (match != null) {
        supportedLanguages.add(match.namedGroup("name")!);
      }
    }
  }

  @override
  String? getBaseUrl() {
    return getString("baseUrl") ?? getAppConfig()?.serverConfig!.baseUrl;
  }

  @override
  Future<bool> setBaseUrl(String? baseUrl) {
    return setString("baseUrl", baseUrl);
  }

  @override
  String? getUsername() {
    return getString("username") ?? getAppConfig()?.serverConfig!.username;
  }

  @override
  Future<bool> setUsername(String? username) {
    return setString("username", username);
  }

  @override
  String? getPassword() {
    return getString("password") ?? getAppConfig()?.serverConfig!.password;
  }

  @override
  Future<bool> setPassword(String? password) {
    return setString("password", password);
  }

  @override
  String? getAuthCode() {
    return getString("authKey");
  }

  @override
  Future<bool> setAuthCode(String? pAuthCode) {
    return setString("authKey", pAuthCode);
  }

  @override
  Map<String, String> getAppStyle() {
    _loadAppStyle();
    return applicationStyle!;
  }

  @override
  Future<bool> setAppStyle(Map<String, String>? pAppStyle) async {
    if (pAppStyle == null) {
      applicationStyle?.clear();
    } else {
      applicationStyle = pAppStyle;
    }

    bool success = await setString("applicationStyle", pAppStyle != null ? jsonEncode(pAppStyle) : null);

    callbacks['style']?.forEach((element) => element.call());
    return success;
  }

  @override
  double getOpacityMenu() {
    _loadAppStyle();
    return double.parse(applicationStyle!['opacity.menu'] ?? '1');
  }

  @override
  double getOpacitySideMenu() {
    _loadAppStyle();
    return double.parse(applicationStyle!['opacity.sidemenu'] ?? '1');
  }

  @override
  double getOpacityControls() {
    _loadAppStyle();
    return double.parse(applicationStyle!['opacity.controls'] ?? '1');
  }

  void _loadAppStyle() {
    if (applicationStyle == null) {
      String? jsonMap = getString("applicationStyle");
      applicationStyle = (jsonMap != null ? Map<String, String>.from(jsonDecode(jsonMap)) : null) ?? {};
    }
  }

  @override
  int? getPictureResolution() {
    return sharedPrefs.getInt("${getAppName()}.pictureSize");
  }

  @override
  Future<bool> setPictureResolution(int pictureResolution) {
    return sharedPrefs.setInt("${getAppName()}.pictureSize", pictureResolution);
  }

  @override
  bool isOffline() {
    return offlineNotifier?.value ?? sharedPrefs.getBool("${getAppName()}.offline") ?? false;
  }

  @override
  ValueNotifier<bool> getOfflineNotifier() {
    offlineNotifier ??= ValueNotifier(isOffline());
    return offlineNotifier!;
  }

  @override
  Future<bool> setOffline(bool pOffline) {
    offlineNotifier?.value = pOffline;
    return sharedPrefs.setBool("${getAppName()}.offline", pOffline);
  }

  @override
  String? getOfflineScreen() {
    return getString("offlineScreen");
  }

  @override
  Future<bool> setOfflineScreen(String pWorkscreen) {
    return setString("offlineScreen", pWorkscreen);
  }

  @override
  String? getString(String key) {
    return sharedPrefs.getString("${getAppName()}.$key");
  }

  @override
  Future<bool> setString(String key, String? value) {
    if (value != null) {
      return sharedPrefs.setString("${getAppName()}.$key", value);
    } else {
      return sharedPrefs.remove("${getAppName()}.$key");
    }
  }

  // ------------------------------

  @override
  String translateText(String pText) {
    String? translatedText = translation.translations[pText];
    if (translatedText == null) {
      return pText;
    }
    return translatedText;
  }

  @override
  AppConfig? getAppConfig() {
    return appConfig;
  }

  ///Only call if you know what you do!
  setAppConfig(AppConfig? pAppConfig, [bool devConfig = false]) async {
    appConfig = pAppConfig;
    if (devConfig) {
      if (pAppConfig?.serverConfig!.appName != null) {
        await setAppName(null);
      }
      if (pAppConfig?.serverConfig!.baseUrl != null) {
        await setBaseUrl(null);
      }
      if (pAppConfig?.serverConfig!.username != null) {
        await setUsername(null);
      }
      if (pAppConfig?.serverConfig!.password != null) {
        await setPassword(null);
      }
    }
  }

  @override
  Map<String, dynamic> getStartupParameters() {
    return startupParameters;
  }

  @override
  void setStartupParameter({required String pKey, required dynamic pValue}) {
    startupParameters[pKey] = pValue;
  }

  @override
  void registerLanguageCallback(Function(String language) pCallback) {
    registerCallback("language", pCallback);
  }

  @override
  void disposeLanguageCallback(Function(String language) pCallback) {
    disposeCallback("language", pCallback);
  }

  @override
  void disposeLanguageCallbacks() {
    disposeCallbacks("language");
  }

  @override
  void registerStyleCallback(Function() pCallback) {
    registerCallback("style", pCallback);
  }

  @override
  void disposeStyleCallback(Function() pCallback) {
    disposeCallback("style", pCallback);
  }

  @override
  void disposeStyleCallbacks() {
    disposeCallbacks("style");
  }

  @override
  void registerImagesCallback(Function() pCallback) {
    registerCallback("images", pCallback);
  }

  @override
  void disposeImagesCallback(Function() pCallback) {
    disposeCallback("images", pCallback);
  }

  @override
  void disposeImagesCallbacks() {
    disposeCallbacks("images");
  }

  @override
  void imagesChanged() {
    callbacks['images']?.forEach((element) => element.call());
  }

  @override
  Size? getPhoneSize() {
    return phoneSize;
  }

  @override
  void setPhoneSize(Size? pPhoneSize) {
    phoneSize = pPhoneSize;
  }

  @override
  ValueNotifier<LayoutMode> getLayoutMode() {
    return layoutMode;
  }

  @override
  bool isMobileOnly() {
    return sharedPrefs.getBool("${getAppName()}.mobileOnly") ?? false;
  }

  @override
  Future<bool> setMobileOnly(bool pMobileOnly) {
    return sharedPrefs.setBool("${getAppName()}.mobileOnly", pMobileOnly);
  }

  @override
  bool isWebOnly() {
    return sharedPrefs.getBool("${getAppName()}.webOnly") ?? false;
  }

  @override
  Future<bool> setWebOnly(bool pWebOnly) {
    return sharedPrefs.setBool("${getAppName()}.webOnly", pWebOnly);
  }

  @override
  void setApplicationSettings(ApplicationSettingsResponse pApplicationSettings) {
    applicationSettings = pApplicationSettings;
    //Trigger setState
    callbacks['style']?.forEach((element) => element.call());
  }

  @override
  ApplicationSettingsResponse getApplicationSettings() {
    return applicationSettings;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void registerCallback(String type, Function pCallback) {
    callbacks.putIfAbsent(type, () => []).add(pCallback);
  }

  void disposeCallback(String type, Function pCallback) {
    callbacks[type]?.remove(pCallback);
  }

  void disposeCallbacks(String type) {
    callbacks[type]?.clear();
  }

  void _loadLanguage(String pLanguage) {
    Translation langTrans = Translation.empty();

    // Load the default translation.
    File? defaultTransFile = fileManager.getFileSync(pPath: "${IFileManager.LANGUAGES_PATH}/translation.json");
    langTrans.merge(defaultTransFile);

    if (pLanguage != "en") {
      File? transFile = fileManager.getFileSync(pPath: "${IFileManager.LANGUAGES_PATH}/translation_$pLanguage.json");
      if (transFile == null) {
        FlutterJVx.logUI.v("Translation file for code $pLanguage could not be found");
      } else {
        langTrans.merge(transFile);
      }
    }

    translation = langTrans;

    callbacks['language']?.forEach((element) => element.call(pLanguage));
  }
}
