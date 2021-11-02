import 'package:flutter_jvx/src/models/events/menu/menu_added_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnMenuAddedEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<MenuAddedEvent> get menuAddedEventStream => _eventBus.on<MenuAddedEvent>();

  void fireMenuAddedEvent(MenuAddedEvent event) {
    _eventBus.fire(event);
  }

}