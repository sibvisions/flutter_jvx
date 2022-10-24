import '../../../../../../services.dart';
import '../../../../../model/command/api/save_all_editors.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class SaveAllEditorsCommandProcessor implements ICommandProcessor<SaveAllEditorsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAllEditorsCommand command) async {
    return IUiService().collectAllEditorSaveCommands(command.componentId);
  }
}
