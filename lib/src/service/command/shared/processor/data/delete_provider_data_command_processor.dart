import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/delete_provider_data_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class DeleteProviderDataCommandProcessor extends ICommandProcessor<DeleteProviderDataCommand> with DataServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(DeleteProviderDataCommand command) async {
    await dataService.deleteDataFromDataBook(
      pDataProvider: command.dataProvider,
      pFrom: command.fromIndex,
      pTo: command.toIndex,
      pDeleteAll: command.deleteAll,
    );
    return [];
  }
}
