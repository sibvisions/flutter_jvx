import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/set_values_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SetValuesProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<SetValuesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValuesCommand command) {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      return apiService.setValues(
        clientId: clientId,
        componentId: command.componentId,
        columnNames: command.columnNames,
        values: command.values,
        dataProvider: command.dataProvider,
      );
    } else {
      throw Exception("NO CLIENT ID FOUND while trying to send setValues request. CommandID: " + command.id.toString());
    }
  }
}
