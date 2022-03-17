import 'dart:isolate';

import '../../../../../../model/api/requests/tab_open_request.dart';
import '../api_isolate_message.dart';

class ApiIsolateOpenTabMessage extends ApiIsolateMessage {
  final TabOpenRequest tabOpenRequest;

  ApiIsolateOpenTabMessage({required this.tabOpenRequest});

  @override
  sendResponse({required response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
