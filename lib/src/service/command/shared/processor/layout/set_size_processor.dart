import 'package:flutter_client/src/mixin/layout_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/set_size_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SetSizeProcessor with LayoutServiceMixin implements ICommandProcessor<SetSizeCommand>{

  @override
  Future<List<BaseCommand>> processCommand(SetSizeCommand command) async {
    layoutService.setSize(setSize: command.size, id: command.componentId);
    return [];
  }

}