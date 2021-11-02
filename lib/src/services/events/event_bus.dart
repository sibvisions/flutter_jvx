import 'dart:async';

class EventBus {

  final StreamController _streamController = StreamController.broadcast();


  Stream<T> on<T>() {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  void fire(event) {
    _streamController.add(event);
  }

}