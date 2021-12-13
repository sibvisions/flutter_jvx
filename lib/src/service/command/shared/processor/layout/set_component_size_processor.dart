import '../../../../../mixin/layout_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/set_component_size_command.dart';
import '../../i_command_processor.dart';

class SetComponentSizeProcessor with LayoutServiceMixin implements ICommandProcessor<SetComponentSizeCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetComponentSizeCommand command) async {
    return layoutService.setComponentSize(id: command.componentId, size: command.size);
  }
}
