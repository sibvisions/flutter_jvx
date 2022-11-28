import 'dart:async';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/delete_frame_command.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class DeleteFrameCommandProcessor implements ICommandProcessor<DeleteFrameCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteFrameCommand command) async {
    IUiService().closeFrame(componentId: command.componentId);
    return [];
  }
}
