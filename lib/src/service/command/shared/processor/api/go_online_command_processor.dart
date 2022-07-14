import '../../../../../model/command/api/go_online_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class GoOnlineCommandProcessor implements ICommandProcessor<GoOnlineCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(GoOnlineCommand command) async {
    // TODO going offline

    return [];
  }
}
