import 'dart:ui';

import 'package:flutter_jvx/src/models/events/base_event.dart';

class PerformRenderEvent extends BaseEvent {

  final String id;
  final Size size;

  PerformRenderEvent({
    required Object origin,
    required String reason,
    required this.id,
    required this.size,
  }) : super(origin: origin, reason: reason);


}