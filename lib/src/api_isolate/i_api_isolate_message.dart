import 'dart:isolate';

///
/// Used as a base Type for Communication with the API Isolate
///
abstract class ApiIsolateMessage {

  ///Id will be used to identify the response of the isolate
  final String messageId ;

  ///SendPort where results will be sent to;
  final SendPort sendPort;

  ApiIsolateMessage({required this.sendPort}) :
    messageId = DateTime.now().microsecondsSinceEpoch.toString();


  ///Returns new Instance, does not copy sendPort Instance.
  ApiIsolateMessage.from({required ApiIsolateMessage message}) :
    messageId = message.messageId,
    sendPort = message.sendPort;
}