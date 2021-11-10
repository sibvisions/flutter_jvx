import 'package:flutter_jvx/src/models/events/base_event.dart';

class RegisterParentEvent extends BaseEvent {

  final String id;
  final String layout;
  final List<String> childrenIds;

  RegisterParentEvent({
    required Object origin,
    required String reason,
    required this.id,
    required this.layout,
    required this.childrenIds
  }) : super(origin: origin, reason: reason);


}