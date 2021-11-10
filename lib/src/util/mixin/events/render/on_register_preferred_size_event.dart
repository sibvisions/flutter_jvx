import 'package:flutter_jvx/src/models/events/render/register_preferred_size_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnRegisterPreferredSizeEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<RegisterPreferredSizeEvent> get registerPreferredSizeEventStream => _eventBus.on<RegisterPreferredSizeEvent>();

  void fireRegisterPreferredSizeEvent(RegisterPreferredSizeEvent event){
    _eventBus.fire(event);
  }
}