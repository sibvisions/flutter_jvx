import 'dart:isolate';

import 'package:flutter_client/src/model/api/requests/i_api_request.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/api_isolate_message.dart';

/// Used to send [IApiRequest] to the APIs isolate to be executed
class ApiIsolateRequestMessage extends ApiIsolateMessage<List<BaseCommand>> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The request to be executed
  final IApiRequest request;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateRequestMessage({required this.request});

  sendResponse({required List<BaseCommand> pResponse, required SendPort pSendPort}) {
    pSendPort.send(pResponse);
  }
}
