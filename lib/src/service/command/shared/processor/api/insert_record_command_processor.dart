import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_insert_record_request.dart';
import 'package:flutter_client/src/model/command/api/insert_record_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class InsertRecordCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<InsertRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(InsertRecordCommand command) {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      return apiService.sendRequest(
          request: ApiInsertRecordRequest(
        dataProvider: command.dataProvider,
        clientId: clientId,
      ));
    } else {
      return SynchronousFuture([]);
    }
  }
}
