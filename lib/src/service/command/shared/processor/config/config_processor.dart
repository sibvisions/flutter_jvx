import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/client_id_command.dart';
import '../../../../../model/command/config/config_command.dart';
import '../../i_command_processor.dart';
import 'client_id_command_processor.dart';


///
/// Processes [ConfigCommand], delegates them to their respective [ICommandProcessor]
///
class ConfigProcessor implements ICommandProcessor<ConfigCommand> {


  final ClientIdProcessor _clientIdProcessor = ClientIdProcessor();

  @override
  Future<List<BaseCommand>> processCommand(ConfigCommand command) async {

    if(command is ClientIdCommand){
      return _clientIdProcessor.processCommand(command);
    } else {
      return [];
    }
  }

}