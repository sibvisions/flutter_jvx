import 'package:flutter_jvx/src/models/events/render/unregister_parent_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnUnregisterParentEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<UnregisterParentEvent> get unregisterParentEventStream => _eventBus.on<UnregisterParentEvent>();

  void fireUnregisterParentEvent(UnregisterParentEvent event){
    _eventBus.fire(event);
  }
}