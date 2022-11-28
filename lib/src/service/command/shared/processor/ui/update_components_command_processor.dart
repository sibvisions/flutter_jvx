import 'dart:async';

import '../../../../../flutter_jvx.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class UpdateComponentsCommandProcessor implements ICommandProcessor<UpdateComponentsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command) async {
    final stopwatch = Stopwatch()..start();
    await ILayoutService().setValid(isValid: false);

    // Wait as long as layout is busy
    bool isBusy = true;
    while (isBusy) {
      isBusy = await ILayoutService().layoutInProcess();

      if (isBusy) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    // Update components when current layout run is finished
    await ILayoutService().setValid(isValid: true);
    stopwatch.stop();

    if (stopwatch.elapsedMilliseconds > 50) {
      FlutterJVx.logUI.w("Layout was busy for ${stopwatch.elapsedMilliseconds}ms");
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
    });

    return [];
  }
}
