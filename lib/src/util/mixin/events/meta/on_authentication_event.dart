import 'package:flutter_jvx/src/models/events/meta/authentication_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnAuthenticationEvent {

  final EventBus _eventBus = services<EventBus>();

  Stream<AuthenticationEvent> get authenticationEventStream => _eventBus.on<AuthenticationEvent>();

  void fireAuthenticationEvent(AuthenticationEvent event){
    _eventBus.fire(event);
  }


}