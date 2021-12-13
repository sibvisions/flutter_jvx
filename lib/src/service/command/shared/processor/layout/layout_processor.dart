import '../../../../../model/command/layout/register_parent_command.dart';
import '../../../../../model/command/layout/set_component_size_command.dart';
import 'register_parent_processor.dart';
import 'set_component_size_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../i_command_processor.dart';
import 'preferred_size_processor.dart';

class LayoutProcessor implements ICommandProcessor {
  final PreferredSizeProcessor _preferredSizeProcessor = PreferredSizeProcessor();
  final RegisterParentProcessor _registerParentCommand = RegisterParentProcessor();
  final SetComponentSizeProcessor _componentSizeProcessor = SetComponentSizeProcessor();

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
