import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/delete_provider_data_command.dart';
import '../../../../data/i_data_service.dart';
import '../../i_command_processor.dart';

class DeleteProviderDataCommandProcessor extends ICommandProcessor<DeleteProviderDataCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(DeleteProviderDataCommand command) async {
    await IDataService().deleteDataFromDataBook(
      pDataProvider: command.dataProvider,
      pFrom: command.fromIndex,
      pTo: command.toIndex,
      pDeleteAll: command.deleteAll,
    );
    return [];
  }
}
