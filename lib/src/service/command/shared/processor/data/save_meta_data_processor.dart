import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../i_command_processor.dart';

class SaveMetaDataProcessor with DataServiceMixin implements ICommandProcessor<SaveMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveMetaDataCommand command) async {
    dataService.updateMetaData(pMetaData: command.response);

    return [];
  }
}
