import 'package:flutterclient/src/util/config/widget_config.dart';

import '../../services/remote/handler/i_socket_handler.dart';
import '../../ui/screen/core/manager/i_screen_manager.dart';
import '../../ui/screen/core/manager/screen_manager.dart';
import '../../util/app/listener/app_listener.dart';
import '../../util/app/version/app_version.dart';
import '../../util/config/app_config.dart';
import '../../util/config/dev_config.dart';
import '../../util/config/server_config.dart';
import '../../util/download/file_config.dart';
import '../../util/translation/translation_config.dart';
import '../api/response_objects/application_meta_data_response_object.dart';
import '../api/response_objects/application_style/application_style_response_object.dart';
import '../api/response_objects/device_status_response_object.dart';
import '../api/response_objects/language_response_object.dart';
import '../api/response_objects/menu/menu_item.dart';
import '../api/response_objects/menu/menu_response_object.dart';
import '../api/response_objects/user_data_response_object.dart';
import 'application_parameters.dart';

/// State of the application
class AppState {
  /// Config for the app
  AppConfig? appConfig;

  /// Config for the connection to the server
  ServerConfig? serverConfig;

  /// Config for developers
  DevConfig? devConfig;

  /// App Meta Data from the server
  ApplicationMetaDataResponseObject? applicationMetaData;

  /// UserData from the server
  UserDataResponseObject? userData;

  /// DeviceStatus object
  DeviceStatusResponseObject? deviceStatus;

  /// Language Response from the server
  LanguageResponseObject? language;

  /// Translation files
  TranslationConfig translationConfig = TranslationConfig();

  /// App Style response from the server
  ApplicationStyleResponseObject? applicationStyle;

  /// File locations
  FileConfig fileConfig = FileConfig();

  /// Current Menu entries
  MenuResponseObject menuResponseObject =
      MenuResponseObject(name: 'menu', entries: <MenuItem>[]);

  /// Application Parameters from the server
  ApplicationParameters parameters = ApplicationParameters();

  /// App version for custom apps
  AppVersion? appVersion;

  /// Only show mobile frame
  bool mobileOnly = false;

  /// Only show web frame
  bool webOnly = false;

  /// How many records the app should fetch ahead
  int readAheadLimit = 100;

  /// Directory of the flutter app
  String baseDirectory = '';

  /// Picsize which will be used to scale taken images
  int picSize = 320;

  /// When the app is in offline mode
  bool isOffline = false;

  /// Manager for custom screens
  IScreenManager screenManager = ScreenManager();

  /// Listener for events from server
  AppListener? listener;

  /// Socket Handler manages connections
  ISocketHandler? socketHandler;

  /// Current screen menu comp id
  String? currentMenuComponentId;

  /// Config for widgets
  WidgetConfig widgetConfig = WidgetConfig();

  bool showsLoading = false;

  AppState();
}
