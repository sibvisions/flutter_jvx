import '../../../features/custom_screen/handler/i_socket_handler.dart';
import '../../ui/frames/i_app_frame.dart';
import '../../ui/screen/i_screen_manager.dart';
import '../../utils/app/listener/app_listener.dart';
import '../api/response/application_style_response.dart';
import '../api/response/menu_item.dart';

class AppState {
  String username;
  String password;
  String baseUrl;
  String appName;
  String appMode ;
  String language;
  int picSize;
  String appVersion;
  int readAheadLimit = 100;
  Map<String, dynamic> translation = <String, dynamic>{};
  bool mobileOnly = false;
  bool webOnly = false;
  IAppFrame appFrame;
  ApplicationStyleResponse applicationStyle;
  String displayName;
  String profileImage;
  List roles;
  String clientId;
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
  }
}
