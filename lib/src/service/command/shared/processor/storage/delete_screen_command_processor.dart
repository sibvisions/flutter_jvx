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
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/component/fl_component_model.dart';
import '../../../../../routing/locations/work_screen_location.dart';
import '../../../../data/i_data_service.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../storage/i_storage_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class DeleteScreenCommandProcessor implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    if (command.beamBack && IUiService().getCurrentWorkscreenName() == command.screenName) {
      FlutterUI.getBeamerDelegate().beamBack();
    } else {
      FlutterUI.getBeamerDelegate().beamingHistory.whereType<WorkScreenLocation>().forEach((workscreenLocation) {
        workscreenLocation.history
            .removeWhere((element) => element.routeInformation.location?.endsWith(command.screenName) == true);
      });
    }
    FlComponentModel? screenModel = IStorageService().getComponentByName(pComponentName: command.screenName);
    IStorageService().deleteScreen(screenName: command.screenName);
    if (screenModel != null) {
      await ILayoutService().deleteScreen(pComponentId: screenModel.id);
    }
    IDataService().clearData(command.screenName);

    return [];
  }
}
