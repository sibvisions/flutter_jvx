import 'package:flutter_jvx/src/models/events/base_event.dart';
import 'package:flutter_jvx/src/models/events/render/register_parent_event.dart';

class UnregisterParentEvent extends BaseEvent {

  final String id;

  UnregisterParentEvent({
    required Object origin,
    required String reason,
    required this.id,
  }) : super(origin: origin, reason: reason);
}