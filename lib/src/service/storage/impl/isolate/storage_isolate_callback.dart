import 'dart:isolate';

import '../default/storage_service.dart';
import 'message/endpoint/storage_isolate_delete_screen_message.dart';
import 'message/endpoint/storage_isolate_get_screen_message.dart';
import 'message/endpoint/storage_isolate_update_components_message.dart';
import 'message/storage_isolate_message.dart';
import 'message/storage_isolate_message_wrapper.dart';

void storageCallback(SendPort callerSendPort) {
  // Instantiate a SendPort to receive message from the caller
  ReceivePort isolateReceivePort = ReceivePort();

  // Provide the caller with the reference of THIS isolate's SendPort
  callerSendPort.send(isolateReceivePort.sendPort);

  // Storage instance holds all data.
  final StorageService componentStore = StorageService();

  isolateReceivePort.listen((message) async {
    StorageIsolateMessageWrapper isolateMessageWrapper = (message as StorageIsolateMessageWrapper);
    StorageIsolateMessage isolateMessage = isolateMessageWrapper.message;
    dynamic response;

    if (isolateMessage is StorageIsolateGetScreenMessage) {
      response = await componentStore.getScreenByScreenClassName(isolateMessage.screenClassName);
    } else if (isolateMessage is StorageIsolateUpdateComponentsMessage) {
      response = await componentStore.updateComponents(
          isolateMessage.componentsToUpdate, isolateMessage.newComponents, isolateMessage.screenClassName);
    } else if (isolateMessage is StorageIsolateDeleteScreenMessage) {
      await componentStore.deleteScreen(screenName: isolateMessage.screenName);
    }

    if (response != null) {
      isolateMessage.sendResponse(response: response, sendPort: isolateMessageWrapper.sendPort);
    }
  });
}
