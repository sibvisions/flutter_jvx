import 'package:flutter_jvx/src/models/config/api/config_api_static.dart';
import 'package:flutter_jvx/src/models/config/endpoint/config_api_endpoints_v1_static.dart';
import 'package:flutter_jvx/src/models/config/url/config_api_url_static.dart';
import 'package:flutter_jvx/src/services/api/controller/jvx_controller.dart';
import 'package:flutter_jvx/src/services/api/i_controller.dart';
import 'package:flutter_jvx/src/services/api/i_repository.dart';
import 'package:flutter_jvx/src/services/api/repository/jvx_online_repository.dart';
import 'package:flutter_jvx/src/services/component/i_component_store_service.dart';
import 'package:flutter_jvx/src/services/component/v1/component_store_service.dart';
import 'package:flutter_jvx/src/services/configs/app/config_app_static.dart';
import 'package:flutter_jvx/src/services/configs/i_config_app.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/events/ui/ui_event_service.dart';
import 'package:flutter_jvx/src/services/events/i_menu_service.dart';
import 'package:flutter_jvx/src/services/events/menu/menu_event_service.dart';
import 'package:flutter_jvx/src/services/events/i_render_service.dart';
import 'package:flutter_jvx/src/services/events/render/render_event_servide.dart';
import 'package:flutter_jvx/src/services/events/i_routing_service.dart';
import 'package:flutter_jvx/src/services/events/routing/routing_event_service.dart';
import 'package:flutter_jvx/src/services/service.dart';

void initApp(){

  //Order of Registration is important as they may depend on another.

  EventBus eventBus = EventBus();
  services.registerSingleton(eventBus, signalsReady:  true);

  IRoutingService routingService = RoutingEventService();
  services.registerSingleton(routingService, signalsReady: true);

  IMenuService menuService = MenuEventService();
  services.registerSingleton(menuService, signalsReady: true);


  IConfigApp configAppService = ConfigAppService( pAppName: "demo", pTheme: "light" );
  services.registerSingleton(configAppService, signalsReady: true);

  ConfigApiEndpointsV1Static apiEndpointsV1Static = ConfigApiEndpointsV1Static();
  ConfigApiUrlStatic apiUrlStatic = ConfigApiUrlStatic(
      pIsHttps: false,
      pHost: "172.16.0.59",
      pPort: 8090,
      pPath: "/JVx.mobile/services/mobile"
  );

  IComponentStoreService componentStoreService = ComponentStoreService();
  services.registerSingleton(componentStoreService, signalsReady: true);

  ConfigApiStatic api = ConfigApiStatic(endpointConfig: apiEndpointsV1Static, urlConfig: apiUrlStatic);
  IRepository apiRepository = JVxOnlineRepository(apiConfig: api);
  services.registerSingleton(apiRepository, signalsReady: true);

  IController apiController = JVxController();
  services.registerSingleton(apiController, signalsReady: true);


  UiEventService uiEventService = UiEventService();
  services.registerSingleton(uiEventService, signalsReady: true);





  IRenderService renderService = RenderEventService();
  services.registerSingleton(renderService, signalsReady: true);

}