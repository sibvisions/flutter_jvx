import 'dart:developer';

import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../i_command_processor.dart';

class UpdateComponentsProcessor with UiServiceGetterMixin implements ICommandProcessor<UpdateComponentsCommand>{

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {

    getUiService().updateComponentModels(modelsToUpdate: command.affectedComponents);
    return [];
  }

}