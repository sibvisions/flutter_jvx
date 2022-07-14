import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../i_command_processor.dart';

class SaveComponentsProcessor
    with StorageServiceMixin, UiServiceGetterMixin
    implements ICommandProcessor<SaveComponentsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveComponentsCommand command) async {
    List<BaseCommand> commands = [];

    commands.addAll(
      await storageService.updateComponents(
        command.updatedComponent,
        command.componentsToSave,
        command.screenName,
      ),
    );

    return commands;
  }
}
