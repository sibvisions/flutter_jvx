import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/save_menu_command.dart';
import '../../i_command_processor.dart';

class SaveMenuCommandProcessor implements ICommandProcessor<SaveMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveMenuCommand command) {
    IUiService().setMenuModel(command.menuModel);
    return Future.value([]);
  }
}
