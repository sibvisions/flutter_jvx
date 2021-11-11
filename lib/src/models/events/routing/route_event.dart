import 'package:flutter_jvx/src/models/events/base_event.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';

class RouteEvent extends BaseEvent {
  final RoutingOptions routeTo;
  final String? workScreenClassname;


  RouteEvent({
    required this.routeTo,
    required Object origin,
    required String reason,
    this.workScreenClassname
  }) : super (reason: reason, origin: origin);


  @override
  String toString() {
    return "Route Event - Route to: $routeTo, reason: $reason, origin: $origin";
  }
}