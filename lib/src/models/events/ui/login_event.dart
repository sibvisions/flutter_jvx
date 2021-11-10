import 'package:flutter_jvx/src/models/events/base_event.dart';

class LoginEvent extends BaseEvent {
  final String username;
  final String password;
  final bool rememberMe;

  LoginEvent({
    required this.username,
    required this.password,
    this.rememberMe = false,
    required Object origin,
    required String reason
  }) : super(reason: reason, origin: origin);


}