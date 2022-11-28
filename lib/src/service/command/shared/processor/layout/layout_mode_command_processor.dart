import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/layout_mode_command.dart';
import '../../../../../model/response/device_status_response.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

class LayoutModeCommandProcessor implements ICommandProcessor<LayoutModeCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LayoutModeCommand command) async {
    IConfigService().getLayoutMode().value = command.layoutMode ?? LayoutMode.Small;

    return [];
  }
}
