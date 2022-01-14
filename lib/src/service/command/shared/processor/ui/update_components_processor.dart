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
  static bool isOpenScreen = false;
  static bool _secondRun = false;

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {
    IUiService uiService = getUiService();

    log("------------------- Components are updating");

    if (!isOpenScreen && !_secondRun) {
      layoutService.setValid(isValid: false);
    }

    // Check to see if layout is currently busy
    Future isLegal = Future.doWhile(() async {
      bool isBusy = await layoutService.layoutInProcess();

      if (isBusy) {
        await Future.delayed(const Duration(milliseconds: 2));
      }

      return isBusy;
    });

    // Update components when current layout run is finished
    isLegal.then((_) {
      if (!isOpenScreen && !_secondRun) {
        layoutService.setValid(isValid: true);

        _secondRun = isOpenScreen;
        isOpenScreen = false;
      }

      List<Future> futureList = [];
      futureList.addAll(command.affectedComponents.map((e) => layoutService.markLayoutAsDirty(pComponentId: e)));
      futureList.addAll(command.changedComponents.map((e) => layoutService.markLayoutAsDirty(pComponentId: e.id)));

      // Update Components in UI after all are marked as dirty
      Future.wait(futureList).then((value) {
        uiService.deleteInactiveComponent(inactiveIds: command.deletedComponents);

        uiService.saveNewComponents(newModels: command.newComponents);

        uiService.notifyChangedComponents(updatedModels: command.changedComponents);

        uiService.notifyAffectedComponents(affectedIds: command.affectedComponents);

        log("------------------- Components are finished updating");
      });
    });

    return [];
  }
}
