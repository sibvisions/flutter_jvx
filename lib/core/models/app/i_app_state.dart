import '../../../features/custom_screen/handler/i_socket_handler.dart';
import '../../ui/frames/i_app_frame.dart';
import '../../ui/screen/i_screen_manager.dart';
import '../../utils/app/listener/app_listener.dart';
import '../api/response/application_style_response.dart';
import '../api/response/menu_item.dart';

abstract class IAppState {
  String username;
  String password;
  String baseUrl;
  String appName;
  String appMode;
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

  copyFromOther(IAppState appState);
}
