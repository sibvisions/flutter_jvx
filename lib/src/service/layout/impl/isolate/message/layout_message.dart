import 'dart:isolate';

abstract class LayoutMessage<T> {

  sendResponse({required T response, required SendPort sendPort});
}