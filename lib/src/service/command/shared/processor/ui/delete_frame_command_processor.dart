import 'dart:async';

import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/delete_frame_command.dart';
import '../../i_command_processor.dart';

class DeleteFrameCommandProcessor implements ICommandProcessor<DeleteFrameCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteFrameCommand command) async {
    IUiService().closeFrame(componentId: command.componentId);
    return [];
  }
}
