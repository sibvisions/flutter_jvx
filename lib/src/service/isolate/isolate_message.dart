import 'dart:isolate';

/// Base class for all messages to the API isolate.
/// [T] indicates what return value is expected
/// from the execution of the message.
abstract class IsolateMessage<T> {
  //TODO remove every wrapper message and co&kg
  sendResponse({required T? pResponse, required SendPort pSendPort}) {
    pSendPort.send(pResponse);
  }
}
