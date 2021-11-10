import 'package:flutter_jvx/src/models/events/render/register_parent_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnRegisterParentEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<RegisterParentEvent> get registerParentEventStream => _eventBus.on<RegisterParentEvent>();

  void fireRegisterParentEvent(RegisterParentEvent event){
    _eventBus.fire(event);
  }
}