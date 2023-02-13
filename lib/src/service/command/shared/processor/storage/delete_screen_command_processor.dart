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

import 'package:flutter/foundation.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/component/fl_component_model.dart';
import '../../../../../routing/locations/work_screen_location.dart';
import '../../../../data/i_data_service.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../storage/i_storage_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor implements ICommandProcessor<DeleteScreenCommand> {
  /// Removes every trace of this screen.
  ///
  /// If we are in the web ([kIsWeb]), we don't try to manipulate the history, as it makes no sense
  /// without also manipulating browser history (which is not possible).
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    FlComponentModel? screenModel = IStorageService().getComponentByName(pComponentName: command.screenName);

    if (screenModel is FlPanelModel) {
      if (command.beamBack && IUiService().getCurrentWorkscreenName() == screenModel.screenNavigationName) {
        FlutterUI.getBeamerDelegate().beamBack();
      } else if (!kIsWeb) {
        FlutterUI.getBeamerDelegate().beamingHistory.whereType<WorkScreenLocation>().forEach((workscreenLocation) {
          workscreenLocation.history.removeWhere(
              (element) => element.routeInformation.location?.endsWith(screenModel.screenNavigationName!) ?? false);
        });
      }
    }

    IStorageService().deleteScreen(screenName: command.screenName);
    if (screenModel != null) {
      await ILayoutService().deleteScreen(pComponentId: screenModel.id);
    }
    IDataService().clearData(command.screenName);

    return [];
  }
}
