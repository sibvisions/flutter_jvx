import 'dart:isolate';

abstract class StorageIsolateMessage<T> {

  sendResponse({required T response, required SendPort sendPort});
}