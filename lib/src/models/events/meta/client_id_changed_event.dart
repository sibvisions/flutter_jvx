import 'package:flutter_jvx/src/models/events/base_event.dart';

class ClientIdEvent extends BaseEvent {

  ///New clientID or null if the old one is now invalid
  ///and no new one can be provided.
  final String? clientId;

  ClientIdEvent({
    required this.clientId,
    required Object origin,
    required String reason,
  }) : super(origin: origin, reason: reason);


}