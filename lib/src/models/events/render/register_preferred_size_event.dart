import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/models/events/base_event.dart';

class RegisterPreferredSizeEvent extends BaseEvent {

  final String id;
  final String parent;
  final String constraints;
  final Size size;

  RegisterPreferredSizeEvent({
    required Object origin,
    required String reason,
    required this.id,
    required this.parent,
    required this.size,
    required this.constraints
  }) : super(origin: origin, reason: reason);

}