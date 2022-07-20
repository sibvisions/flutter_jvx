import 'dart:isolate';

import '../../../isolate/isolate_message_wrapper.dart';
import '../../../isolate/isolate_message.dart';
import '../layout_service.dart';
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

  final LayoutService layoutStorage = LayoutService();

  // Handle incoming requests
  isolateReceivePort.listen((message) async {
    // Extract message
    IsolateMessageWrapper isolateMessageWrapper = message as IsolateMessageWrapper;
    IsolateMessage isolateMessage = isolateMessageWrapper.message;
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
    } else if (isolateMessage is RemoveLayoutMessage) {
      response = await layoutStorage.removeLayout(pComponentId: isolateMessage.componentId);
    }

    isolateMessage.sendResponse(pResponse: response, pSendPort: isolateMessageWrapper.sendPort);
  });
}
