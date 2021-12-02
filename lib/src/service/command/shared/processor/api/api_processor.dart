import '../../../../../model/command/api/device_status_command.dart';
import 'device_status_processor.dart';

import '../../../../../model/command/api/api_command.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';
import 'login_command_processor.dart';
import 'open_screen_commmand_processor.dart';
import 'start_up_command_processor.dart';

///
/// Processes all [ApiCommand], delegates all commands to their respective [ICommandProcessor].
///
// Author: Michael Schober
class ApiProcessor implements ICommandProcessor<ApiCommand> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Processes [StartupCommand]
  final ICommandProcessor _startUpProcessorCommand = StartUpCommandProcessor();

  /// Processes [LoginCommand]
  final ICommandProcessor _loginCommandProcessor = LoginCommandProcessor();

  /// Processes [OpenScreenCommand]
  final ICommandProcessor _openScreenCommandProcessor = OpenScreenCommandProcessor();

  /// Processes [DeviceStatusCommand]
  final ICommandProcessor _deviceStatusProcessor = DeviceStatusProcessor();

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
    } else if(command is DeviceStatusCommand){
      return _deviceStatusProcessor.processCommand(command);
    } else {
      return [];
    }
  }
}