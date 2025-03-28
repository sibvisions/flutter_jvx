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

import '../../../../commands.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/generic_screen_view_response.dart';
import '../../../config/i_config_service.dart';
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
  List<BaseCommand> processResponse(GenericScreenViewResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];

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
    }

    // Handle Screen Opening
    // if update == false => new screen that should be routed to
    if (!pResponse.update && !IConfigService().offline.value) {
      if (panel?.screenNavigationName != null) {
        commands.add(RouteToWorkScreenCommand(
          screenName: panel!.screenNavigationName!,
          reason: "Server sent screen.generic response with update = 'false'",
        ));
      } else {
        FlutterUI.logUI.w("Server sent screen.generic response with update = 'false' but no panel with a matching screen name");
      }
    }

    return commands;
  }
}
