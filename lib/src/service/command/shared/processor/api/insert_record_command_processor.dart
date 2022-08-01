import 'package:flutter/foundation.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/request/api_insert_record_request.dart';
import '../../../../../model/command/api/insert_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class InsertRecordCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<InsertRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(InsertRecordCommand command) {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      return getApiService().sendRequest(
          request: ApiInsertRecordRequest(
        dataProvider: command.dataProvider,
        clientId: clientId,
      ));
    } else {
      return SynchronousFuture([]);
    }
  }
}
