import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../i_command_processor.dart';

class SaveComponentsCommandProcessor with StorageServiceMixin implements ICommandProcessor<SaveComponentsCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SaveComponentsCommand command) async {
    storageService.saveComponent(command.componentsToSave);
    return [];
  }
}