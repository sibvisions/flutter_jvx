import 'package:flutter_jvx/src/models/events/menu/menu_changed_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnMenuChangedEvent{
  final EventBus _eventBus = services<EventBus>();

  Stream<MenuChangedEvent> get menuChangedStream => _eventBus.on<MenuChangedEvent>();

  void fireMenuChangedEvent(MenuChangedEvent event){
    _eventBus.fire(event);
  }
}