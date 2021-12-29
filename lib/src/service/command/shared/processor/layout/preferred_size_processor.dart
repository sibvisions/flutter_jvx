import '../../../../../mixin/layout_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../i_command_processor.dart';

class PreferredSizeProcessor with LayoutServiceMixin implements ICommandProcessor<PreferredSizeCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PreferredSizeCommand command) async {
    return layoutService.reportPreferredSize(pLayoutData: command.layoutData);
  }
}
