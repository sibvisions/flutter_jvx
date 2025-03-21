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

import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/view/message/message_dialog_response.dart';
import '../i_response_processor.dart';

class MessageDialogProcessor implements IResponseProcessor<MessageDialogResponse> {
  @override
  List<BaseCommand> processResponse(MessageDialogResponse pResponse, ApiRequest? pRequest) {
    return [
      OpenMessageDialogCommand(
        componentName: pResponse.componentId,
        closable: pResponse.closable,
        buttonType: pResponse.buttonType,
        iconType: pResponse.iconType,
        okComponentName: pResponse.okComponentId,
        notOkComponentName: pResponse.notOkComponentId,
        cancelComponentName: pResponse.cancelComponentId,
        okText: pResponse.okText,
        notOkText: pResponse.notOkText,
        cancelText: pResponse.cancelText,
        title: pResponse.title,
        message: pResponse.message,
        dataProvider: pResponse.dataProvider,
        columnName: pResponse.columnName,
        inputLabel: pResponse.inputLabel,
        reason: "Message.dialog from server",
      )
    ];
  }
}
