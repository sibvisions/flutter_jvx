import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../../../storage/i_storage_service.dart';
import '../../i_command_processor.dart';

class SaveComponentsCommandProcessor implements ICommandProcessor<SaveComponentsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveComponentsCommand command) async {
    List<BaseCommand> commands = [];

    commands.addAll(
      IStorageService().saveComponents(
        command.updatedComponent,
        command.componentsToSave,
        command.screenName,
      ),
    );

    return commands;
  }
}
