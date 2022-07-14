import 'dart:isolate';

import '../default/api_service.dart';
import 'messages/api_isolate_api_config_message.dart';
import 'messages/api_isolate_controller_message.dart';
import 'messages/api_isolate_message.dart';
import 'messages/api_isolate_message_wrapper.dart';
import 'messages/api_isolate_repository_message.dart';
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
    ApiIsolateMessageWrapper messageWrapper = message as ApiIsolateMessageWrapper;
    ApiIsolateMessage apiMessage = messageWrapper.message;

    // Handle setup messages
    if (apiMessage is ApiIsolateControllerMessage) {
      apiService.controller = apiMessage.controller;
    } else if (apiMessage is ApiIsolateRepositoryMessage) {
      apiService.repository = apiMessage.repository;
    } else if (apiMessage is ApiIsolateRequestMessage) {
      var response = await apiService.sendRequest(request: apiMessage.request);
      messageWrapper.sendPort.send(response);
    } else if (apiMessage is ApiIsolateApiConfigMessage) {
      apiService.setApiConfig(apiConfig: apiMessage.apiConfig);
    }
  });
}
