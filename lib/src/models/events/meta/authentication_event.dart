import 'package:flutter_jvx/src/models/events/i_event.dart';

class AuthenticationEvent extends BaseEvent {

  ///The new status of authentication
  final bool authenticationStatus;

  AuthenticationEvent({
    required this.authenticationStatus,
    required Object origin,
    required String reason
  }) : super(origin: origin, reason: reason);
}