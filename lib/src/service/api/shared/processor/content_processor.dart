/* 
 * Copyright 2023 SIB Visions GmbH
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

import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/command/ui/function_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/content_response.dart';
import '../../../ui/i_ui_service.dart';
import '../fl_component_classname.dart';
import '../i_response_processor.dart';

class ContentProcessor implements IResponseProcessor<ContentResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(ContentResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];

    FlPanelModel? panel;
    // Handle New & Changed Components
    // Get new full components
    if (pResponse.changedComponents != null) {
      SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand(
        components: pResponse.changedComponents!,
        isContent: true,
        isUpdate: pResponse.update,
        reason: "Api received content response",
      );
      commands.add(saveComponentsCommand);

      panel = saveComponentsCommand.componentsToSave?.whereType<FlPanelModel>().firstWhereOrNull((element) =>
          element.classNameEventSourceRef == FlContainerClassname.DIALOG ||
          element.classNameEventSourceRef == FlContainerClassname.CONTENT);
    }

    // Handle Screen Opening
    // if update == false => new screen that should be routed to
    if (!pResponse.update && panel != null) {
      commands.add(
        FunctionCommand(
          reason: "Server sent content response with update = 'false'",
          function: () async {
            IUiService().openContent(panel!.name);

            return [];
          },
        ),
      );
    }

    return commands;
  }
}
