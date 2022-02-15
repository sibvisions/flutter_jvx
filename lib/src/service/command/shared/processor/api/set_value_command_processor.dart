import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/set_value_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';


class SetValueProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<SetValueCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValueCommand command) {
    String? clientId = configService.getClientId();

    if(clientId != null){
      return apiService.setValue(clientId, command.componentId, command.value);
    } else {
      throw Exception("NO CLIENT ID FOUND, while trying to send setValue request. CommandID: " + command.id.toString());
    }
  }
}