import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../i_command_processor.dart';
import 'preferred_size_processort.dart';

class LayoutProcessor implements ICommandProcessor {


  final PreferredSizeProcessor _preferredSizeProcessor = PreferredSizeProcessor();

  @override
  Future<List<BaseCommand>> processCommand(BaseCommand command) async {

    if(command is PreferredSizeCommand){
      return _preferredSizeProcessor.processCommand(command);
    }

    return [];
  }

}