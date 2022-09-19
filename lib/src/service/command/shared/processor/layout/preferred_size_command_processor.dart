import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../../../layout/i_layout_service.dart';
import '../../i_command_processor.dart';

class PreferredSizeCommandProcessor implements ICommandProcessor<PreferredSizeCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PreferredSizeCommand command) {
    return ILayoutService().reportPreferredSize(pLayoutData: command.layoutData);
  }
}
