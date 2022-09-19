import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/register_parent_command.dart';
import '../../../../layout/i_layout_service.dart';
import '../../i_command_processor.dart';

class RegisterParentCommandProcessor implements ICommandProcessor<RegisterParentCommand> {
  @override
  Future<List<BaseCommand>> processCommand(RegisterParentCommand command) {
    return ILayoutService().reportLayout(pLayoutData: command.layoutData);
  }
}
