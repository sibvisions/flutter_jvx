import 'dart:isolate';

import '../../../../../model/api/requests/i_api_request.dart';
import '../../../../../model/command/base_command.dart';
import 'api_isolate_message.dart';

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
