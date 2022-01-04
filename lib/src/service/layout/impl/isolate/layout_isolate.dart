import 'dart:isolate';

import 'package:flutter_client/src/service/layout/impl/isolate/message/endpoint/mark_as_dirty_message.dart';
import 'package:flutter_client/src/service/layout/impl/isolate/message/endpoint/report_layout_message.dart';
import 'package:flutter_client/src/service/layout/impl/isolate/message/endpoint/report_preferred_size_message.dart';
import 'package:flutter_client/src/service/layout/impl/isolate/message/endpoint/set_screen_size_message.dart';
import 'package:flutter_client/src/service/layout/impl/isolate/message/layout_message_wrapper.dart';
import 'package:flutter_client/src/service/layout/impl/layout_service.dart';

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

    if(isolateMessage is MarkAsDirtyMessage){
      layoutStorage.markLayoutAsDirty(pComponentId: isolateMessage.id);
    } else if(isolateMessage is ReportLayoutMessage){
      response = await layoutStorage.reportLayout(pLayoutData: isolateMessage.layoutData);
    } else if(isolateMessage is ReportPreferredSizeMessage) {
      response = await layoutStorage.reportPreferredSize(pLayoutData: isolateMessage.layoutData);
    } else if(isolateMessage is SetScreenSizeMessage) {
      response = await layoutStorage.setScreenSize(pScreenComponentId: isolateMessage.componentId, pSize: isolateMessage.size);
    }

    if(response != null){
      isolateMessage.sendResponse(response: response, sendPort: messageWrapper.sendPort);
    }

  });
}