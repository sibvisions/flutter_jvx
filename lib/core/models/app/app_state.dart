import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/core/models/api/response/application_parameters.dart';
import 'package:jvx_flutterclient/core/utils/config/config.dart';

import '../../../features/custom_screen/handler/i_socket_handler.dart';
import '../../ui/frames/i_app_frame.dart';
import '../../ui/screen/i_screen_manager.dart';
import '../../utils/app/listener/app_listener.dart';
import '../api/response/application_style_response.dart';
import '../api/response/menu_item.dart';

/// Current state of the App.
class AppState {
  String username;
  String password;
  String baseUrl;
  String appName;

  /// Current app mode.
  ///
  /// `preview`: Only one menu item will be shown.
  ///
  /// `full`: Every menu item will be shown.
  String appMode = 'full';

  /// Current language of the application.
  String language;

  /// Current picture size.
  ///
  /// `320`, `640` and `1024` are the sizes to choose from.
  int picSize;

  /// App version from the server.
  String appVersion;

  /// States how many lines can be fetched ahead in lazy loading.
  int readAheadLimit = 100;

  /// Avaible translations and their file locations.
  Map<String, dynamic> translation = <String, dynamic>{};

  /// For web. Defines if layout should look mobile style only.
  bool mobileOnly = false;

  /// For web. Defines if layout should look web style only.
  bool webOnly = false;

  /// Current frame for the application.
  ///
  /// `WebFrame`: Frame for web applications.
  ///
  /// `AppFrame`: Default frame and frame for mobile applications.
  IAppFrame appFrame;

  /// Current application style sent from the server.
  ApplicationStyleResponse applicationStyle;

  /// Display name of user shown in [MenuDrawerWidget].
  String displayName;

  /// base64 encoded profile image.
  String profileImage;

  /// Roles of the user.
  List roles;

  /// ClienId sent from the server.
  String clientId;

  /// Parameter from app config.
  bool handleSessionTimeout;
  Map<String, String> files = <String, String>{};
  List<String> images = <String>[];
  String jsessionId;
  String dir;
  AppListener appListener;
  ISocketHandler customSocketHandler;
  String layoutMode;
  List<MenuItem> items;
  IScreenManager screenManager;
  int menuCurrentPageIndex;
  bool package;
  String currentScreenComponentId;
  List<Locale> supportedLocales = [];
  Config config;
  bool offline = false;
  ApplicationParameters applicationParameters;

  bool get isOffline => offline != null ? offline : false;

  AppState();

  copyFromOther(AppState state) {
    this.username = state.username;
    this.password = state.password;
    this.baseUrl = state.baseUrl;
    this.appName = state.appName;
    this.appMode = state.appMode;
    this.language = state.language;
    this.picSize = state.picSize;
    this.appVersion = state.appVersion;
    this.translation = state.translation;
    this.mobileOnly = state.mobileOnly;
    this.webOnly = state.webOnly;
    this.appFrame = state.appFrame;
    this.applicationStyle = state.applicationStyle;
    this.displayName = state.displayName;
    this.profileImage = state.profileImage;
    this.roles = state.roles;
    this.clientId = state.clientId;
    this.handleSessionTimeout = state.handleSessionTimeout;
    this.files = state.files;
    this.images = state.images;
    this.jsessionId = state.jsessionId;
    this.appListener = state.appListener;
    this.layoutMode = state.layoutMode;
    this.screenManager = state.screenManager;
    this.menuCurrentPageIndex = state.menuCurrentPageIndex;
    this.package = state.package;
    this.currentScreenComponentId = state.currentScreenComponentId;
    this.supportedLocales = state.supportedLocales;
    this.config = state.config;
    this.offline = state.offline;
    this.applicationParameters = state.applicationParameters;
  }
}
