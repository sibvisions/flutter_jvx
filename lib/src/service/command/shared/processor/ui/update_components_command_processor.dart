import 'dart:async';

import '../../../../../../flutter_jvx.dart';
import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../i_command_processor.dart';

class UpdateComponentsCommandProcessor implements ICommandProcessor<UpdateComponentsCommand> {
  static bool isOpenScreen = false;
  static bool _secondRun = false;

  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {
    FlutterJVx.log.d("------------------- Components are updating");

    if (!isOpenScreen && !_secondRun) {
      await ILayoutService().setValid(isValid: false);
    }

    // Check to see if layout is currently busy
    Future isLegal = Future.doWhile(() async {
      bool isBusy = await ILayoutService().layoutInProcess();

      if (isBusy) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      return isBusy;
    });

    // Update components when current layout run is finished
    await isLegal.then((_) async {
      if (!isOpenScreen && !_secondRun) {
        await ILayoutService().setValid(isValid: true);

        _secondRun = isOpenScreen;
        isOpenScreen = false;
      }

      List<Future> futureList = [];
      futureList.addAll(command.affectedComponents.map((e) => ILayoutService().markLayoutAsDirty(pComponentId: e)));
      futureList.addAll(command.changedComponents.map((e) => ILayoutService().markLayoutAsDirty(pComponentId: e.id)));
      futureList.addAll(command.deletedComponents.map((e) => ILayoutService().removeLayout(pComponentId: e)));

      // Update Components in UI after all are marked as dirty
      await Future.wait(futureList).then((value) {
        IUiService().deleteInactiveComponent(inactiveIds: command.deletedComponents);

        IUiService().saveNewComponents(newModels: command.newComponents.reversed.toList());

        // List is reversed as to update all children before their respective parents.
        IUiService().notifyChangedComponents(updatedModels: command.changedComponents.reversed.toList());

        IUiService().notifyAffectedComponents(affectedIds: command.affectedComponents);

        FlutterJVx.log.d("------------------- Components are finished updating");
      });
    });

    return [];
  }
}
