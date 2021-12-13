import 'package:flutter_client/src/layout/form_layout.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';

import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/endpoint_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/isolate/isolate_api.dart';
import 'src/service/api/shared/controller/api_controller.dart';
import 'src/service/api/shared/i_controller.dart';
import 'src/service/api/shared/i_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/layout/i_layout_service.dart';
import 'src/service/layout/impl/layout_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/isolate/isolate_storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';

import 'data/config/config_generator.dart';

Future<bool> initAppMobile() async {
  // API
  EndpointConfig endpointConfig = ConfigGenerator.generateFixedEndpoints();
  UrlConfig urlConfig = ConfigGenerator.generateMobileServerUrl("172.16.0.59", 8090);
  ApiConfig apiConfig = ApiConfig(urlConfig: urlConfig, endpointConfig: endpointConfig);
  IRepository repository = OnlineApiRepository(apiConfig: apiConfig);
  IController controller = ApiController();
  IApiService apiService = await IsolateApi.create(controller: controller, repository: repository);
  services.registerSingleton(apiService, signalsReady: true);

  // Config
  IConfigService configService = ConfigService(appName: "demo");
  services.registerSingleton(configService, signalsReady: true);

  // Layout
  ILayoutService layoutService = LayoutService();
  services.registerSingleton(layoutService, signalsReady: true);

  // Storage
  IStorageService storageService = await IsolateStorageService.create();
  services.registerSingleton(storageService, signalsReady: true);

  // Command
  ICommandService commandService = CommandService();
  services.registerSingleton(commandService, signalsReady: true);

  // UI
  IUiService uiService = UiService();
  services.registerSingleton(uiService, signalsReady: true);

  return true;
}
