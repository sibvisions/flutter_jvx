import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/client_id_command.dart';
import '../../i_command_processor.dart';

class ClientIdProcessor with ConfigServiceMixin implements ICommandProcessor<ClientIdCommand> {

  @override
  Future<List<BaseCommand>> processCommand(ClientIdCommand command) async {
    configService.setClientId(command.clientId);
    return [];
  }
}