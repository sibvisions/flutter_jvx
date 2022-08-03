import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/save_menu_command.dart';
import '../../i_command_processor.dart';

class SaveMenuCommandProcessor with UiServiceGetterMixin implements ICommandProcessor<SaveMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveMenuCommand command) {
    getUiService().setMenuModel(command.menuModel);
    return Future.value([]);
  }
}
