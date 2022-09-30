import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/layout_mode_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../../../../model/command/layout/register_parent_command.dart';
import '../../i_command_processor.dart';
import 'layout_mode_command_processor.dart';
import 'preferred_size_command_processor.dart';
import 'register_parent_command_processor.dart';

class LayoutProcessor implements ICommandProcessor {
  final PreferredSizeCommandProcessor _preferredSizeProcessor = PreferredSizeCommandProcessor();
  final RegisterParentCommandProcessor _registerParentCommand = RegisterParentCommandProcessor();
  final LayoutModeCommandProcessor _layoutModeProcessor = LayoutModeCommandProcessor();

  @override
  Future<List<BaseCommand>> processCommand(BaseCommand command) async {
    if (command is PreferredSizeCommand) {
      return _preferredSizeProcessor.processCommand(command);
    } else if (command is RegisterParentCommand) {
      return _registerParentCommand.processCommand(command);
    } else if (command is LayoutModeCommand) {
      return _layoutModeProcessor.processCommand(command);
    }

    return [];
  }
}
