import 'package:flutter_client/src/mixin/storage_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/storage/save_components_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SaveComponentsCommandProcessor with StorageServiceMixin implements ICommandProcessor<SaveComponentsCommand> {

  @override
  Future<List<BaseCommand>> processCommand(SaveComponentsCommand command) async {
    storageService.saveComponent(command.componentsToSave);
    return [];
  }
}