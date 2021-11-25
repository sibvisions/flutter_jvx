import 'dart:developer';

import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/update_components_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class UpdateComponentsProcessor with UiServiceGetterMixin implements ICommandProcessor<UpdateComponentsCommand>{

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {

    log("in Update Processor");
    getUiService().updateComponentModels(command.affectedComponents);
    return [];
  }

}