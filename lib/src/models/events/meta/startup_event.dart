import 'package:flutter_jvx/src/models/events/i_event.dart';

class StartupEvent extends BaseEvent {

  StartupEvent({
    required Object origin,
    required String reason
  }) : super(origin: origin, reason: reason);
}