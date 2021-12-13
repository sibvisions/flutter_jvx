import 'dart:developer';

import 'package:flutter_client/src/mixin/layout_service_mixin.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../i_command_processor.dart';

class UpdateComponentsProcessor with UiServiceGetterMixin, LayoutServiceMixin implements ICommandProcessor<UpdateComponentsCommand>{

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {

    IUiService uiService = getUiService();


    // Set Dirty in layoutService
    for(String affected in command.affectedComponents){
      layoutService.markLayoutAsDirty(id: affected);
    }
    for(FlComponentModel changed in command.changedComponents){
      layoutService.markLayoutAsDirty(id: changed.id);
    }


    // Update Components in UI

    uiService.deleteInactiveComponent(inactiveIds: command.deletedComponents);

    uiService.saveNewComponents(newModels: command.newComponents);

    uiService.notifyChangedComponents(updatedModels: command.changedComponents);

    uiService.notifyAffectedComponents(affectedIds: command.affectedComponents);


    return [];
  }

}