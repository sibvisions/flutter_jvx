import 'package:flutter_jvx/src/models/events/menu/menu_button_pressed_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnMenuButtonPressedEvent{
  final EventBus _eventBus = services<EventBus>();

  Stream<MenuButtonPressedEvent> get menuButtonPressedEventStream => _eventBus.on<MenuButtonPressedEvent>();

  void fireMenuButtonPressedEvent(MenuButtonPressedEvent event){
    _eventBus.fire(event);
  }

}