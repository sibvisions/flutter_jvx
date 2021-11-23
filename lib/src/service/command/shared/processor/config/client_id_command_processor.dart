import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/client_id_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class ClientIdProcessor with ConfigServiceMixin implements ICommandProcessor<ClientIdCommand> {

  @override
  Future<List<BaseCommand>> processCommand(ClientIdCommand command) async {
    configService.setClientId(command.clientId);
    return [];
  }
}