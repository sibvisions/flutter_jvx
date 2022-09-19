import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../../../data/i_data_service.dart';
import '../../i_command_processor.dart';

class SaveMetaDataCommandProcessor implements ICommandProcessor<SaveMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveMetaDataCommand command) async {
    await IDataService().updateMetaData(pMetaData: command.response);

    return [];
  }
}
