import 'dart:async';

import 'package:flutter_jvx/src/models/events/i_event.dart';

class EventBus {

  final StreamController _streamController = StreamController.broadcast();


  Stream<T> on<T>() {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  void fire(BaseEvent event) {
    _streamController.add(event);
  }

}