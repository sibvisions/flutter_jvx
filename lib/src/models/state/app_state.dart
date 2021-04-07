import 'package:flutterclient/src/ui/screen/core/manager/screen_manager.dart';

import '../../services/remote/handler/i_socket_handler.dart';
import '../../ui/screen/core/manager/i_screen_manager.dart';
import '../../util/app/listener/app_listener.dart';
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

class AppState {
  AppConfig? appConfig;
  ServerConfig? serverConfig;
  DevConfig? devConfig;
  ApplicationMetaDataResponseObject? applicationMetaData;
  UserDataResponseObject? userData;
  DeviceStatusResponseObject? deviceStatus;
  LanguageResponseObject? language;
  TranslationConfig translationConfig = TranslationConfig();
  ApplicationStyleResponseObject? applicationStyle;
  FileConfig fileConfig = FileConfig();
  MenuResponseObject menuResponseObject =
      MenuResponseObject(name: 'menu', entries: <MenuItem>[]);

  bool mobileOnly = false;
  bool webOnly = false;

  int readAheadLimit = 100;
  String baseDirectory = '';
  int picSize = 320;

  bool isOffline = false;

  IScreenManager screenManager = ScreenManager();
  AppListener? listener;
  ISocketHandler? socketHandler;

  String? currentMenuComponentId;

  AppState();
}
