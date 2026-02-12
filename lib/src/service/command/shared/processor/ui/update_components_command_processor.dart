/*
 * Copyright 2022 SIB Visions GmbH
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
import '../../../../../util/jvx_logger.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../storage/i_storage_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class UpdateComponentsCommandProcessor extends ICommandProcessor<UpdateComponentsCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateComponentsCommand command, BaseCommand? origin) async {

    if (command.affectedComponents.isEmpty
        && command.changedComponents.isEmpty
        && command.deletedComponents.isEmpty
        && command.newComponents.isEmpty
        && !command.notifyDesktopPanel) {
      return [];
    }

    // Wait as long as layout is busy
    bool isBusy = await ILayoutService().layoutInProcess();

    if (isBusy) {
      final stopwatch = Stopwatch()..start();

      bool wasValid = await ILayoutService().isValid();

      if (wasValid) {
        await ILayoutService().setValid(isValid: false);
      }

      while (isBusy) {
        await Future.delayed(const Duration(milliseconds: 10));

        isBusy = await ILayoutService().layoutInProcess();
      }

      if (wasValid) {
        // Update components when current layout run is finished
        await ILayoutService().setValid(isValid: true);
      }
      stopwatch.stop();

      if (stopwatch.elapsedMilliseconds > 50) {
        if (FlutterUI.logUI.cl(Lvl.w)) {
          FlutterUI.logUI.w("Layout was busy for ${stopwatch.elapsedMilliseconds}ms");
        }
      }
    }

    if (command.affectedComponents.isEmpty
        && command.changedComponents.isEmpty
        && command.deletedComponents.isEmpty
        && command.newComponents.isEmpty
        && command.notifyDesktopPanel) {
      IStorageService().getDesktopPanelNotifier().notify();
    } else {

      List<Future> futureList = [];
      if (command.affectedComponents.isNotEmpty) {
        futureList.addAll(command.affectedComponents.map((e) => ILayoutService().markLayoutAsDirty(pComponentId: e)));
      }

      if (command.changedComponents.isNotEmpty) {
        futureList.addAll(command.changedComponents.map((e) => ILayoutService().markLayoutAsDirty(pComponentId: e)));
      }

      if (command.deletedComponents.isNotEmpty) {
        futureList.addAll(command.deletedComponents.map((e) => ILayoutService().removeLayout(pComponentId: e)));
      }

      if (futureList.isEmpty) {
        if (command.newComponents.isNotEmpty) {
          IUiService().notifyModels();

          if (command.notifyDesktopPanel) {
            IStorageService().getDesktopPanelNotifier().notify();
          }
        }
      }
      else {
        // Update Components in UI after all are marked as dirty
        await Future.wait(futureList).then((value) {
          if (value.isNotEmpty) {
            IUiService().notifyModelUpdated(command.changedComponents);
            IUiService().notifyAffectedComponents(command.affectedComponents);
            IUiService().notifyModels();

            if (command.notifyDesktopPanel) {
              IStorageService().getDesktopPanelNotifier().notify();
            }
          }
        });
      }
    }

    return [];
  }
}
