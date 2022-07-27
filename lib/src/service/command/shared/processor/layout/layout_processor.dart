import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../../../../model/command/layout/register_parent_command.dart';
import '../../../../../model/command/layout/set_component_size_command.dart';
import '../../i_command_processor.dart';
import 'preferred_size_command_processor.dart';
import 'register_parent_command_processor.dart';
import 'set_component_size_command_processor.dart';

class LayoutProcessor implements ICommandProcessor {
  final PreferredSizeCommandProcessor _preferredSizeProcessor = PreferredSizeCommandProcessor();
  final RegisterParentCommandProcessor _registerParentCommand = RegisterParentCommandProcessor();
  final SetComponentSizeCommandProcessor _componentSizeProcessor = SetComponentSizeCommandProcessor();

  @override
  Future<List<BaseCommand>> processCommand(BaseCommand command) async {
    if (command is PreferredSizeCommand) {
      return _preferredSizeProcessor.processCommand(command);
    } else if (command is RegisterParentCommand) {
      return _registerParentCommand.processCommand(command);
    } else if (command is SetComponentSizeCommand) {
      return _componentSizeProcessor.processCommand(command);
    }

    return [];
  }
}
