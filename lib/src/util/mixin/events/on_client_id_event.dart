import 'package:flutter_jvx/src/models/events/meta/client_id_changed_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnClientIdEvent{
  final EventBus _eventBus = services<EventBus>();

  Stream<ClientIdEvent> get authenticationEventStream => _eventBus.on<ClientIdEvent>();

  void fireClientIdEvent(ClientIdEvent event){
    _eventBus.fire(event);
  }
}