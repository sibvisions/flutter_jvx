import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../../model/command/ui/data_book_updated_command.dart';
import '../../i_command_processor.dart';

class SaveFetchDataProcessor with DataServiceMixin implements ICommandProcessor<SaveFetchDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveFetchDataCommand command) async {
    await dataService.updateData(pFetch: command.response);

    DataBookUpdatedCommand dataBookUpdatedCommand =
        DataBookUpdatedCommand(reason: "Fetch has updated Data", dataProvider: command.response.dataProvider);

    return [dataBookUpdatedCommand];
  }
}
