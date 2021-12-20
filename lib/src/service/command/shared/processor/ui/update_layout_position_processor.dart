import 'dart:developer';

import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../i_command_processor.dart';

class UpdateLayoutPositionProcessor
    with UiServiceGetterMixin
    implements ICommandProcessor<UpdateLayoutPositionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateLayoutPositionCommand command) async {
    var uiService = getUiService();
    command.layoutPosition.forEach((key, value) {
      uiService.setLayoutPosition(id: key, layoutData: value);
    });

    return [];
  }
}
