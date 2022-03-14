import 'dart:isolate';

import 'package:flutter_client/src/model/api/requests/tab_close_request.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/api_isolate_message.dart';

class ApiIsolateCloseTabMessage extends ApiIsolateMessage{

  final TabCloseRequest tabCloseRequest;

  ApiIsolateCloseTabMessage({
    required this.tabCloseRequest
  });

  @override
  sendResponse({required response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}