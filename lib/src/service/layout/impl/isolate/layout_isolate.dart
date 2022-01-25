import 'dart:isolate';

import 'message/endpoint/layout_in_process_message.dart';
import 'message/endpoint/layout_valid_message.dart';

import 'message/endpoint/mark_as_dirty_message.dart';
import 'message/endpoint/report_layout_message.dart';
import 'message/endpoint/report_preferred_size_message.dart';
import 'message/endpoint/set_screen_size_message.dart';
import 'message/layout_message_wrapper.dart';
import '../layout_service.dart';

import 'message/layout_message.dart';

void layoutIsolate(SendPort callerSendPort) {
  // Instantiate a SendPort to receive message from the caller
  ReceivePort isolateReceivePort = ReceivePort();

  // Provide the caller with the reference of THIS isolate's SendPort
  callerSendPort.send(isolateReceivePort.sendPort);

  final LayoutService layoutStorage = LayoutService();

  isolateReceivePort.listen((message) async {
    LayoutMessageWrapper messageWrapper = (message as LayoutMessageWrapper);
    LayoutMessage isolateMessage = messageWrapper.message;

    dynamic response;

    if (isolateMessage is MarkAsDirtyMessage) {
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
    }

    if (response != null) {
      isolateMessage.sendResponse(response: response, sendPort: messageWrapper.sendPort);
    }
  });
}
