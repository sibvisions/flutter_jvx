import 'package:flutter_jvx/src/models/events/meta/startup_event.dart';
import 'package:flutter_jvx/src/services/events/event_bus.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin OnStartupEvent {
  final EventBus _eventBus = services<EventBus>();

  Stream<StartupEvent> get startupEventStream => _eventBus.on<StartupEvent>();

  void fireStartupEvent(StartupEvent event){
    _eventBus.fire(event);
  }
}