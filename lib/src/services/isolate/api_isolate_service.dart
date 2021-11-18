import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/request/open_screen_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/startup_message.dart';
import 'package:flutter_jvx/src/api_isolate/response/api_isolate_response.dart';
import 'package:flutter_jvx/src/models/api/action/component_action.dart';
import 'package:flutter_jvx/src/models/api/action/menu_action.dart';
import 'package:flutter_jvx/src/models/api/action/meta_action.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/action/route_action.dart';
import 'package:flutter_jvx/src/models/events/menu/menu_added_event.dart';
import 'package:flutter_jvx/src/models/events/routing/route_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_menu_added_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/routing/on_routing_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/component_store_sevice_mixin.dart';
import 'package:flutter_jvx/src/util/mixin/service/config_app_service_mixin.dart';


class ApiIsolateService with ConfigAppServiceMixin, OnRoutingEvent, OnMenuAddedEvent, ComponentStoreServiceMixin {

  ///The Api Isolate reference
  final Isolate apiIsolate;

  ///Port to send messages to the isolate
  final SendPort sendPort;

  ///Port where the answer will be received
  final ReceivePort receivePort = ReceivePort();

  ApiIsolateService({required this.sendPort, required this.apiIsolate}){
    receivePort.listen((message) {_receivedAnswer(message);});
  }


  _receivedAnswer(dynamic response) {
    if(response is ApiIsolateResponse) {
      for(ProcessorAction action in response.actions){
        if(action is MetaAction) {
          configAppService.clientId = action.clientId;
        } else if(action is ComponentAction){
          componentStoreService.saveComponent(action.componentModel);
        } else if(action is MenuAction) {
          var menuAddedEvent = MenuAddedEvent(
              reason: "Api call resulted in new Menu being sent",
              origin: this,
              menu: action.menu
          );
          fireMenuAddedEvent(menuAddedEvent);
        } else if(action is RouteAction){

        }
      }

      int index = response.actions.indexWhere((element) => element is RouteAction);
      if(index != -1) {
        RouteAction routeAction = (response.actions[index] as RouteAction);
        var routeEvent = RouteEvent(
            routeTo: routeAction.routingOptions,
            origin: this,
            reason: "Api call resulted in routeAction"
        );
        fireRoutingEvent(routeEvent);
      }
    }
  }


  startUp() {
    sendPort.send(
        StartupMessage(sendPort: receivePort.sendPort)
    );
  }

  openScreen(String componentId) {
    sendPort.send(
        OpenScreenMessage(componentId: componentId, sendPort: receivePort.sendPort)
    );
  }


}


