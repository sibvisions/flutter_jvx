import 'dart:developer';

import '../../../../api/shared/fl_component_classname.dart';

import '../../../../../mixin/layout_service_mixin.dart';
import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class UpdateComponentsProcessor
    with UiServiceGetterMixin, LayoutServiceMixin
    implements ICommandProcessor<UpdateComponentsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {
    IUiService uiService = getUiService();

    log("------------------- Component are updating");

    await layoutService.setValid(isValid: false);

    while (await layoutService.layoutInProcess()) {}

    await layoutService.setValid(isValid: true);

    List<Future> futureList = [];
    futureList.addAll(command.affectedComponents.map((e) => layoutService.markLayoutAsDirty(pComponentId: e)));
    futureList.addAll(command.changedComponents.map((e) => layoutService.markLayoutAsDirty(pComponentId: e.id)));

    // Update Components in UI after all are marked as dirty
    Future.wait(futureList).then((value) {
      uiService.deleteInactiveComponent(inactiveIds: command.deletedComponents);

      uiService.saveNewComponents(newModels: command.newComponents);

      uiService.notifyChangedComponents(updatedModels: command.changedComponents);

      uiService.notifyAffectedComponents(affectedIds: command.affectedComponents);

      log("------------------- Component are finished updating");
    });

    return [];
  }
}
