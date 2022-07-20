import 'dart:isolate';

import '../../../isolate/isolate_message_wrapper.dart';
import '../../../isolate/isolate_message.dart';
import '../default/api_service.dart';
import 'messages/api_isolate_api_config_message.dart';
import 'messages/api_isolate_controller_message.dart';
import 'messages/api_isolate_get_repository_message.dart';
import 'messages/api_isolate_set_repository_message.dart';
import 'messages/api_isolate_request_message.dart';

void apiCallback(SendPort callerSendPort) {
  // Instantiate a SendPort to receive message from the caller
  ReceivePort isolateReceivePort = ReceivePort();

  // Provide the caller with the reference of THIS isolate's SendPort
  callerSendPort.send(isolateReceivePort.sendPort);

  // Api service to handle all incoming requests
  final ApiService apiService = ApiService.empty();

  // Handle incoming requests
  isolateReceivePort.listen((message) async {
    // Extract message
    IsolateMessageWrapper isolateMessageWrapper = message as IsolateMessageWrapper;
    IsolateMessage isolateMessage = isolateMessageWrapper.message;
    dynamic response;

    // Handle setup messages
    if (isolateMessage is ApiIsolateControllerMessage) {
      apiService.controller = isolateMessage.controller;
    } else if (isolateMessage is ApiIsolateSetRepositoryMessage) {
      await apiService.setRepository(isolateMessage.repository);
    } else {
      if (isolateMessage is ApiIsolateApiConfigMessage) {
        apiService.setApiConfig(apiConfig: isolateMessage.apiConfig);
      } else if (isolateMessage is ApiIsolateGetRepositoryMessage) {
        response = await apiService.getRepository();
      } else if (isolateMessage is ApiIsolateRequestMessage) {
        response = await apiService.sendRequest(request: isolateMessage.request);
      }
    }

    isolateMessage.sendResponse(pResponse: response, pSendPort: isolateMessageWrapper.sendPort);
  });
}
