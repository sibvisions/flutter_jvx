import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../i_command_processor.dart';

class SaveFetchDataCommandProcessor implements ICommandProcessor<SaveFetchDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveFetchDataCommand command) async {
    await IDataService().updateData(pFetch: command.response);

    IUiService().notifyDataChange(
      pDataProvider: command.response.dataProvider,
    );

    return [];
  }
}
