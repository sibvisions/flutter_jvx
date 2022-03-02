import 'dart:isolate';

import '../../../../../../model/api/requests/set_values_request.dart';
import '../../../../../../model/command/base_command.dart';
import '../api_isolate_message.dart';

class ApiIsolateSetValuesMessage extends ApiIsolateMessage<List<BaseCommand>> {
  /// Request to be made
  final SetValuesRequest setValuesRequest;

  ApiIsolateSetValuesMessage({required this.setValuesRequest});

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
