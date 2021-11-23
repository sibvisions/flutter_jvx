import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/client_id_command.dart';
import 'package:flutter_client/src/model/command/config/config_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/config/client_id_command_processor.dart';


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