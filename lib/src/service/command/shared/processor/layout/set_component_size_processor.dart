import 'package:flutter_client/src/mixin/layout_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/layout/set_component_size_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class SetComponentSizeProcessor with LayoutServiceMixin implements ICommandProcessor<SetComponentSizeCommand>{

  @override
  Future<List<BaseCommand>> processCommand(SetComponentSizeCommand command) async {
    return layoutService.setComponentSize(id: command.componentId, size: command.size);
  }
}