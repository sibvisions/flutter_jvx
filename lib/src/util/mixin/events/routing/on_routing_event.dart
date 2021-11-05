import 'package:flutter_jvx/src/models/events/routing/route_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnRoutingEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<RouteEvent> get routeEventStream => _eventBus.on<RouteEvent>();

  void fireRoutingEvent(RouteEvent event){
    _eventBus.fire(event);
  }
}