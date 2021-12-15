import '../../../../../mixin/layout_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/register_parent_command.dart';
import '../../i_command_processor.dart';

class RegisterParentProcessor with LayoutServiceMixin implements ICommandProcessor<RegisterParentCommand> {
  @override
  Future<List<BaseCommand>> processCommand(RegisterParentCommand command) async {
    return layoutService.registerAsParent(pLayoutData: command.layoutData);
  }
}
