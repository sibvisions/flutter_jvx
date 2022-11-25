import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/function_command.dart';
import '../../i_command_processor.dart';

class FunctionCommandProcessor extends ICommandProcessor<FunctionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(FunctionCommand command) async {
    return await command.function.call();
  }
}
