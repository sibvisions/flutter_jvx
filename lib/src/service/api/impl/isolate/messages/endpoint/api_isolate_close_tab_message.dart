import 'dart:isolate';

import '../../../../../../model/api/requests/tab_close_request.dart';
import '../api_isolate_message.dart';

class ApiIsolateCloseTabMessage extends ApiIsolateMessage {
  final TabCloseRequest closeTabRequest;

  ApiIsolateCloseTabMessage({required this.closeTabRequest});

  @override
  sendResponse({required response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
