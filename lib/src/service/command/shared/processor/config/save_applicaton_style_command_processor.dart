import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_application_style_command.dart';
import '../../i_command_processor.dart';

class SaveApplicationStyleCommandProcessor implements ICommandProcessor<SaveApplicationStyleCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveApplicationStyleCommand command) async {
    await IConfigService().setAppStyle(command.style);
    return [];
  }
}
