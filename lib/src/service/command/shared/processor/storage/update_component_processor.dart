import 'package:flutter_client/src/mixin/storage_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/storage/update_component_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/storage/i_storage_service.dart';

/// Processes [UpdateComponentCommand] calls [IStorageService] to update components.
//Author: Michael Schober
class UpdateComponentProcessor with StorageServiceMixin implements ICommandProcessor<UpdateComponentCommand> {

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentCommand command) async {
    storageService.updateComponent(command.changedComponents);
    return [];
  }
}