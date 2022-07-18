import 'dart:isolate';

import 'package:flutter_client/src/service/api/shared/i_repository.dart';

import '../../../../../model/command/base_command.dart';
import 'api_isolate_message.dart';

/// Used to send [IRepository] to the APIs isolate to be executed
class ApiIsolateRepositoryMessage extends ApiIsolateMessage<List<BaseCommand>> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The request to be executed
  final IRepository repository;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateRepositoryMessage({required this.repository});

  sendResponse({required List<BaseCommand> pResponse, required SendPort pSendPort}) {
    pSendPort.send(pResponse);
  }
}
