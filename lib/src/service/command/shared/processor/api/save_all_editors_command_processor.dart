import '../../../../../model/command/api/save_all_editors.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class SaveAllEditorsCommandProcessor implements ICommandProcessor<SaveAllEditorsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAllEditorsCommand command) async {
    List<BaseCommand> commands = IUiService().collectAllEditorSaveCommands(command.componentId);

    if (command.thenFunctionCommand != null) {
      commands.add(command.thenFunctionCommand!);
    }

    return commands;
  }
}
