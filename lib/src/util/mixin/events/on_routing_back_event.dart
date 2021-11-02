import 'package:flutter_jvx/src/models/events/routing/route_back_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnRoutingBackEvent {

  final EventBus _eventBus = services<EventBus>();

  Stream<RouteBackEvent> get routeBackEventStream => _eventBus.on<RouteBackEvent>();

  void fireRoutingBackEvent(RouteBackEvent event){
    _eventBus.fire(event);
  }

}