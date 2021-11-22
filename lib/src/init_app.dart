import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/request/app_name_change_message.dart';
import 'package:flutter_jvx/src/models/config/api/config_api_static.dart';
import 'package:flutter_jvx/src/models/config/endpoint/config_api_endpoints_v1_static.dart';
import 'package:flutter_jvx/src/models/config/url/config_api_url_static.dart';
import 'package:flutter_jvx/src/services/api/controller/jvx_controller.dart';
import 'package:flutter_jvx/src/services/api/repository/jvx_online_repository.dart';
import 'package:flutter_jvx/src/services/component/i_component_store_service.dart';
import 'package:flutter_jvx/src/services/component/v1/component_store_service.dart';
import 'package:flutter_jvx/src/services/configs/app/config_app_static.dart';
import 'package:flutter_jvx/src/services/configs/i_config_app.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/events/ui/ui_event_service.dart';
import 'package:flutter_jvx/src/services/events/i_menu_service.dart';
import 'package:flutter_jvx/src/services/events/menu/menu_event_service.dart';
import 'package:flutter_jvx/src/services/events/render/render_event_servide.dart';
import 'package:flutter_jvx/src/services/isolate/api_isolate_service.dart';
import 'package:flutter_jvx/src/services/service.dart';

import 'api_isolate/init_api_isolate.dart';
import 'api_isolate/request/controller_change_message.dart';
import 'api_isolate/request/repository_change_message.dart';

void initApp() async {
  //Order of Registration is important as they may depend on another.

  EventBus eventBus = EventBus();
  services.registerSingleton(eventBus, signalsReady: true);

  IMenuService menuService = MenuEventService();
  services.registerSingleton(menuService, signalsReady: true);

  IConfigApp configAppService = ConfigAppService(pAppName: "demo", pTheme: "light");
  services.registerSingleton(configAppService, signalsReady: true);

  IComponentStoreService componentStoreService = ComponentStoreService();
  services.registerSingleton(componentStoreService, signalsReady: true);

  ApiIsolateService isolateService = await initApi();
  services.registerSingleton(isolateService, signalsReady: true);

  UiEventService uiEventService = UiEventService();
  services.registerSingleton(uiEventService, signalsReady: true);

  RenderEventService renderService = RenderEventService();
  services.registerSingleton(renderService, signalsReady: true);
}

///
/// Spawns separate Isolate to handle all Api actions and returns a [ApiIsolateService]
///
Future<ApiIsolateService> initApi() async {
  ConfigApiEndpointsV1Static apiEndpointsV1Static = ConfigApiEndpointsV1Static();
  ConfigApiUrlStatic apiUrlStatic =
      ConfigApiUrlStatic(pIsHttps: false, pHost: "172.16.0.59", pPort: 8090, pPath: "/JVx.mobile/services/mobile");
  ConfigApiStatic apiConfig = ConfigApiStatic(endpointConfig: apiEndpointsV1Static, urlConfig: apiUrlStatic);

  //Temporary ReceivePort to get the Isolates sendPort
  ReceivePort receivePort = ReceivePort();
  //Spawn Isolate
  Isolate newIsolate = await Isolate.spawn(initApiIsolate, receivePort.sendPort);
  //The SendPort to send request to the new Isolate
  SendPort isolateSendPort = await receivePort.first;

  //Setup
  RepositoryChangeMessage repositoryChangeMessage =
      RepositoryChangeMessage(newRepository: JVxOnlineRepository(apiConfig: apiConfig), sendPort: isolateSendPort);

  ControllerChangeMessage controllerChangeMessage =
      ControllerChangeMessage(newController: JVxController(), sendPort: isolateSendPort);

  AppNameChangeMessage appNameChangeMessage = AppNameChangeMessage(sendPort: isolateSendPort, appName: "demo");

  isolateSendPort.send(repositoryChangeMessage);
  isolateSendPort.send(controllerChangeMessage);
  isolateSendPort.send(appNameChangeMessage);

  //Build Service to send Messages to Isolate easier
  ApiIsolateService requestIsolateService = ApiIsolateService(sendPort: isolateSendPort, apiIsolate: newIsolate);
  return requestIsolateService;
}
