import 'package:flutter_jvx/src/models/events/ui/login_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnLoginEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<LoginEvent> get loginEventStream => _eventBus.on<LoginEvent>();

  void fireLoginEvent(LoginEvent event){
    _eventBus.fire(event);
  }
}