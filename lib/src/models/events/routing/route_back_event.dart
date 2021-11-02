import 'package:flutter_jvx/src/models/events/i_event.dart';

class RouteBackEvent extends BaseEvent {


  RouteBackEvent({
    required Object origin,
    required String reason
  }) : super(origin: origin, reason: reason);

  @override
  String toString() {
    return "RouteBackEvent - reason: $reason, origin: $origin";
  }
}