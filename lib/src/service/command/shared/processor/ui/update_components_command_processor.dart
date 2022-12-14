/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../../../api/shared/fl_component_classname.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../storage/i_storage_service.dart';
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
      FlutterUI.logUI.w("Layout was busy for ${stopwatch.elapsedMilliseconds}ms");
    }

    List<Future> futureList = [];
    futureList.addAll(command.affectedComponents.map((e) => ILayoutService().markLayoutAsDirty(pComponentId: e)));
    futureList.addAll(command.changedComponents.map((e) => ILayoutService().markLayoutAsDirty(pComponentId: e)));
    futureList.addAll(command.deletedComponents.map((e) => ILayoutService().removeLayout(pComponentId: e)));

    // Update Components in UI after all are marked as dirty
    await Future.wait(futureList).then((value) {
      IUiService().notifyChangedComponents(updatedModels: command.changedComponents);

      IUiService().notifyAffectedComponents(affectedIds: command.affectedComponents);

      if (command.screenName == FlContainerClassname.DESKTOP_PANEL) {
        IStorageService().getDesktopPanelNotifier().notify();
      }
    });

    return [];
  }
}
