import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../i_command_processor.dart';

class PreferredSizeCommandProcessor with LayoutServiceMixin implements ICommandProcessor<PreferredSizeCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PreferredSizeCommand command) {
    return getLayoutService().reportPreferredSize(pLayoutData: command.layoutData);
  }
}
