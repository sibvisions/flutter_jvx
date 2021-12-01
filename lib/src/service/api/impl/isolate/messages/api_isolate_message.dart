import 'dart:isolate';

abstract class ApiIsolateMessage<T> {

  sendResponse({required T response, required SendPort sendPort});
}