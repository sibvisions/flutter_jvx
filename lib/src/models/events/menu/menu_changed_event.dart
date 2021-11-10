import 'package:flutter_jvx/src/models/events/base_event.dart';

class MenuChangedEvent extends BaseEvent {

  MenuChangedEvent({
    required String reason,
    required Object origin
  }) : super(reason: reason, origin: origin);
}