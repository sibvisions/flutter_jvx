import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/update_layout_position_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class UpdateLayoutPositionProcessor with UiServiceGetterMixin implements ICommandProcessor<UpdateLayoutPositionCommand>{
  
  
  @override
  Future<List<BaseCommand>> processCommand(UpdateLayoutPositionCommand command) async {
    
    getUiService().updateComponentModels(layoutPositions: command.layoutPosition);
    
    return [];
  }
  
}