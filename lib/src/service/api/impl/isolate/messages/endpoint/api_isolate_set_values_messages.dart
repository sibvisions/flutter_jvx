import 'dart:isolate';

import 'package:flutter_client/src/model/api/requests/set_values_request.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/api_isolate_message.dart';

class ApiIsolateSetValuesMessage extends ApiIsolateMessage<List<BaseCommand>> {

  /// Request to be made
  final SetValuesRequest setValuesRequest;

  ApiIsolateSetValuesMessage({
    required this.setValuesRequest
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }


}