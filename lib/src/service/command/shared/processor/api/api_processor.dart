import 'package:flutter_client/src/model/command/api/api_command.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/login_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/open_screen_commmand_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/start_up_command_processor.dart';

///
/// Processes all [ApiCommand], delegates all commands to their respective [ICommandProcessor].
///
// Author: Michael Schober
class ApiProcessor implements ICommandProcessor<ApiCommand> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ///Processes [StartupCommand]
  final StartUpCommandProcessor _startUpProcessorCommand = StartUpCommandProcessor();

  ///Processes [LoginCommand]
  final LoginCommandProcessor _loginCommandProcessor = LoginCommandProcessor();

  ///Processes [OpenScreenCommand]
  final OpenScreenCommandProcessor _openScreenCommandProcessor = OpenScreenCommandProcessor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(ApiCommand command) async {

    // Switch-Case doesn't work with types
    if(command is StartupCommand){
      return _startUpProcessorCommand.processCommand(command);
    } else if(command is LoginCommand) {
      return _loginCommandProcessor.processCommand(command);
    } else if(command is OpenScreenCommand) {
      return _openScreenCommandProcessor.processCommand(command);
    } else {
      return [];
    }
  }
}