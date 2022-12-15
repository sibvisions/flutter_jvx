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

import 'dart:isolate';

import '../../../isolate/isolate_message.dart';
import '../../../isolate/isolate_message_wrapper.dart';
import '../layout_service.dart';
import 'message/endpoint/clear_message.dart';
import 'message/endpoint/delete_screen_message.dart';
import 'message/endpoint/layout_in_process_message.dart';
import 'message/endpoint/layout_valid_message.dart';
import 'message/endpoint/mark_as_dirty_message.dart';
import 'message/endpoint/remove_layout_message.dart';
import 'message/endpoint/report_layout_message.dart';
import 'message/endpoint/report_preferred_size_message.dart';
import 'message/endpoint/set_screen_size_message.dart';

void layoutCallback(SendPort callerSendPort) {
  // Instantiate a SendPort to receive message from the caller
  ReceivePort isolateReceivePort = ReceivePort();

  // Provide the caller with the reference of THIS isolate's SendPort
  callerSendPort.send(isolateReceivePort.sendPort);

  final LayoutService layoutStorage = LayoutService.create();

  // Handle incoming requests
  isolateReceivePort.listen((message) async {
    // Extract message
    IsolateMessageWrapper isolateMessageWrapper = message as IsolateMessageWrapper;
    IsolateMessage isolateMessage = isolateMessageWrapper.message;
    dynamic response;

    if (isolateMessage is ClearMessage) {
      layoutStorage.clear();
    } else if (isolateMessage is MarkAsDirtyMessage) {
      response = await layoutStorage.markLayoutAsDirty(pComponentId: isolateMessage.id);
    } else if (isolateMessage is ReportLayoutMessage) {
      response = await layoutStorage.reportLayout(pLayoutData: isolateMessage.layoutData);
    } else if (isolateMessage is ReportPreferredSizeMessage) {
      response = await layoutStorage.reportPreferredSize(pLayoutData: isolateMessage.layoutData);
    } else if (isolateMessage is SetScreenSizeMessage) {
      response =
          await layoutStorage.setScreenSize(pScreenComponentId: isolateMessage.componentId, pSize: isolateMessage.size);
    } else if (isolateMessage is LayoutInProcessMessage) {
      response = await layoutStorage.layoutInProcess();
    } else if (isolateMessage is LayoutValidMessage) {
      if (isolateMessage.set) {
        response = await layoutStorage.setValid(isValid: isolateMessage.value);
      } else {
        response = await layoutStorage.isValid();
      }
    } else if (isolateMessage is RemoveLayoutMessage) {
      response = await layoutStorage.removeLayout(pComponentId: isolateMessage.componentId);
    } else if (isolateMessage is DeleteScreenMessage) {
      response = await layoutStorage.deleteScreen(pComponentId: isolateMessage.componentId);
    }

    isolateMessage.sendResponse(pResponse: response, pSendPort: isolateMessageWrapper.sendPort);
  });
}
