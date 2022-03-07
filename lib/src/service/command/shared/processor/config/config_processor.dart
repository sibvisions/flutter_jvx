import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../../../../model/command/config/config_command.dart';
import '../../i_command_processor.dart';
import 'save_app_meta_data_processor.dart';


///
/// Processes [ConfigCommand], delegates them to their respective [ICommandProcessor]
///
class ConfigProcessor implements ICommandProcessor<ConfigCommand> {


  final SaveAppMetaDataProcessor _saveAppMetaDataProcessor = SaveAppMetaDataProcessor();

  @override
  Future<List<BaseCommand>> processCommand(ConfigCommand command) async {

    if(command is SaveAppMetaDataCommand){
      return _saveAppMetaDataProcessor.processCommand(command);
    } else {
      return [];
    }
  }

}