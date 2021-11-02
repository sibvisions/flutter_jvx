import 'package:flutter_jvx/src/models/events/i_event.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';

class RouteEvent extends BaseEvent {
  final RoutingOptions routeTo;


  RouteEvent({
    required this.routeTo,
    required Object origin,
    required String reason
  }) : super (reason: reason, origin: origin);


  @override
  String toString() {
    return "Route Event - Route to: $routeTo, reason: $reason, origin: $origin";
  }
}