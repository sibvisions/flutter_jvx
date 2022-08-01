import 'dart:async';

import '../../../../../../util/logging/flutter_logger.dart';
import '../../../../../mixin/layout_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../i_command_processor.dart';

class UpdateComponentsProcessor
    with UiServiceGetterMixin, LayoutServiceGetterMixin
    implements ICommandProcessor<UpdateComponentsCommand> {
  static bool isOpenScreen = false;
  static bool _secondRun = false;

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {
    LOGGER.logD(pType: LOG_TYPE.COMMAND, pMessage: "------------------- Components are updating");

    if (!isOpenScreen && !_secondRun) {
      await getLayoutService().setValid(isValid: false);
    }

    // Check to see if layout is currently busy
    Future isLegal = Future.doWhile(() async {
      bool isBusy = await getLayoutService().layoutInProcess();

      if (isBusy) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      return isBusy;
    });

    // Update components when current layout run is finished
    await isLegal.then((_) async {
      if (!isOpenScreen && !_secondRun) {
        await getLayoutService().setValid(isValid: true);

        _secondRun = isOpenScreen;
        isOpenScreen = false;
      }

      List<Future> futureList = [];
      futureList.addAll(command.affectedComponents.map((e) => getLayoutService().markLayoutAsDirty(pComponentId: e)));
      futureList.addAll(command.changedComponents.map((e) => getLayoutService().markLayoutAsDirty(pComponentId: e.id)));
      futureList.addAll(command.deletedComponents.map((e) => getLayoutService().removeLayout(pComponentId: e)));

      // Update Components in UI after all are marked as dirty
      await Future.wait(futureList).then((value) {
        getUiService().deleteInactiveComponent(inactiveIds: command.deletedComponents);

        getUiService().saveNewComponents(newModels: command.newComponents.reversed.toList());

        // List is reversed as to update all children before their respective parents.
        getUiService().notifyChangedComponents(updatedModels: command.changedComponents.reversed.toList());

        getUiService().notifyAffectedComponents(affectedIds: command.affectedComponents);

        LOGGER.logD(pType: LOG_TYPE.COMMAND, pMessage: "------------------- Components are finished updating");
      });
    });

    return [];
  }
}
