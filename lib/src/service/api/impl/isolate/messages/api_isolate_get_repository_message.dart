import 'dart:isolate';

import 'package:flutter_client/src/service/api/shared/i_repository.dart';

import '../../../../../model/command/base_command.dart';
import 'api_isolate_message.dart';

/// Used to send [IRepository] to the APIs isolate to be executed
class ApiIsolateGetRepositoryMessage extends ApiIsolateMessage<List<BaseCommand>> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateGetRepositoryMessage();

  sendResponse({required List<BaseCommand> pResponse, required SendPort pSendPort}) {
    pSendPort.send(pResponse);
  }
}
