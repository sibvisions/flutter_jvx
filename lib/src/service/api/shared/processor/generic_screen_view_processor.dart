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

import 'package:collection/collection.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/command/ui/route/route_to_workscreen_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/generic_screen_view_response.dart';
import '../../../../util/misc/active_observer.dart';
import '../../../config/i_config_service.dart';
import '../../../storage/i_storage_service.dart';
import '../api_object_property.dart';
import '../i_response_processor.dart';

/// Processes [GenericScreenViewResponse], will separate (and parse) new and changed components, can also open screens
/// based on the 'update' property of the request.
///
/// Possible return Commands : [SaveComponentsCommand], [RouteCommand]
class GenericScreenViewProcessor implements IResponseProcessor<GenericScreenViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processResponse(GenericScreenViewResponse pResponse, ApiRequest? pRequest) async {
    List<BaseCommand> commands = [];

    String? screenNavigationName;
    bool bActive = false;
    bool bSecure = false;

    FlPanelModel? panel;
    // Handle New & Changed Components
    // Get new full components
    if (pResponse.changedComponents != null) {
      SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
        components: pResponse.changedComponents!,
        componentName: pResponse.componentName,
        isUpdate: pResponse.update,
        reason: "Api received screen.generic response",
      );
      commands.add(saveComponentsCommand);

      panel = saveComponentsCommand.newComponents
          ?.whereType<FlPanelModel>()
          .firstWhereOrNull((element) => element.name == pResponse.componentName);

      if (pResponse.update) {
        //in case of an update, check if the screen itself got activated. In this case, show the screen
        dynamic json = saveComponentsCommand.changedComponents?.firstWhereOrNull((element) {
          if (element is Map) {
            return element.containsKey(ApiObjectProperty.screenActive);
          }
          return false;
        });

        if (json != null) {
          bActive = json[ApiObjectProperty.screenActive] == true;

          FlComponentModel? model = IStorageService().getComponentModel(pComponentId: json[ApiObjectProperty.id]);

          if (model is FlPanelModel && model.isScreen) {
            screenNavigationName = model.screenNavigationName;
            bSecure = model.secure;
          }
        }
      }
    }

    BaseCommand? nextCommand;

    // Handle Screen Opening
    // if update == false => new screen that should be routed to
    if (!IConfigService().offline.value) {
      if (!pResponse.update) {
        if (panel?.screenNavigationName != null) {
          nextCommand = RouteToWorkScreenCommand(
            screenName: panel!.screenNavigationName!,
            secure: panel.secure,
            reason: "Server sent screen.generic response with update = 'false'",
          );
        } else {
          FlutterUI.logUI.w("Server sent screen update = 'false' but we have no panel with a matching screen name");
        }
      }
      else if (bActive) {
        if (screenNavigationName != null) {
          //Just activate the screen
          nextCommand = RouteToWorkScreenCommand(
            screenName: screenNavigationName,
            secure: bSecure,
            reason: "Route to screen from $runtimeType",
          );
        }
        else {
          FlutterUI.logUI.w("Server sent screen activation but we have no panel with a matching screen name");
        }
      }
    }

    if (nextCommand != null) {
      //wait max. 500 millis before the command continues, otherwise the animation is not visible
      ActiveObserver ao = ActiveObserver();
      await ao.waitUntilActiveOrTimeout(Duration(milliseconds: 500));

      commands.add(nextCommand);
    }

    return commands;
  }
}
