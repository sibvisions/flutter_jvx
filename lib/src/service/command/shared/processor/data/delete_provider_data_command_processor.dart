import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/delete_provider_data_command.dart';
import '../../i_command_processor.dart';

class DeleteProviderDataCommandProcessor extends ICommandProcessor<DeleteProviderDataCommand> with DataServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(DeleteProviderDataCommand command) async {
    await getDataService().deleteDataFromDataBook(
      pDataProvider: command.dataProvider,
      pFrom: command.fromIndex,
      pTo: command.toIndex,
      pDeleteAll: command.deleteAll,
    );
    return [];
  }
}
