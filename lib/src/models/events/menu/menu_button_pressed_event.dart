import 'package:flutter_jvx/src/models/events/i_event.dart';

class MenuButtonPressedEvent extends BaseEvent {
  final String componentId;

  MenuButtonPressedEvent({
    required this.componentId,
    required Object origin,
    required String reason,
  }) : super(reason: reason, origin: origin);
}