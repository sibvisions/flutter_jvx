import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../i_command_processor.dart';

class SaveFetchDataCommandProcessor
    with DataServiceMixin, UiServiceMixin
    implements ICommandProcessor<SaveFetchDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveFetchDataCommand command) async {
    await getDataService().updateData(pFetch: command.response);

    getUiService().notifyDataChange(
      pDataProvider: command.response.dataProvider,
      pFrom: command.response.from,
      pTo: command.response.to,
    );

    return [];
  }
}
