import 'dart:isolate';

import 'package:flutter_client/src/service/api/impl/isolate/messages/endpoint/api_isolate_close_tab_message.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/endpoint/api_isolate_download_images_message.dart';

import 'messages/endpoint/api_isolate_set_value_message.dart';
import 'messages/endpoint/api_isolate_set_values_messages.dart';
import 'package:http/http.dart';

import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';
import 'messages/api_isolate_controller_message.dart';
import 'messages/api_isolate_message.dart';
import 'messages/api_isolate_message_wrapper.dart';
import 'messages/api_isolate_repository_message.dart';
import 'messages/endpoint/api_isolate_device_status_message.dart';
import 'messages/endpoint/api_isolate_login_message.dart';
import 'messages/endpoint/api_isolate_open_screen_message.dart';
import 'messages/endpoint/api_isolate_press_button_message.dart';
import 'messages/endpoint/api_isolate_startup_message.dart';

void apiCallback(SendPort callerSendPort) {
  // Instantiate a SendPort to receive message from the caller
  ReceivePort isolateReceivePort = ReceivePort();

  // Provide the caller with the reference of THIS isolate's SendPort
  callerSendPort.send(isolateReceivePort.sendPort);

  /// [IRepository] instance
  IRepository? repository;

  /// [IController] instance
  IController? controller;

  /// Handle incoming requests
  isolateReceivePort.listen((message) async {
//Setup messages
    ApiIsolateMessageWrapper messageWrapper = message as ApiIsolateMessageWrapper;
    ApiIsolateMessage apiMessage = messageWrapper.message;

    if (apiMessage is ApiIsolateControllerMessage) {
      controller = apiMessage.controller;
    } else if (apiMessage is ApiIsolateRepositoryMessage) {
      repository = apiMessage.repository;
    }

    // To be able to promote variable
    IRepository? repo = repository;
    IController? cont = controller;

    if (repo != null && cont != null) {
      // Possible Response
      Future<Response>? response;
      if (apiMessage is ApiIsolateStartUpMessage) {
        response = repo.startUp(apiMessage.appName);
      } else if (apiMessage is ApiIsolateLoginMessage) {
        response = repo.login(apiMessage.userName, apiMessage.password, apiMessage.clientId);
      } else if (apiMessage is ApiIsolateDeviceStatusMessage) {
        response = repo.deviceStatus(apiMessage.clientId, apiMessage.screenWidth, apiMessage.screenHeight);
      } else if (apiMessage is ApiIsolateOpenScreenMessage) {
        response = repo.openScreen(apiMessage.componentId, apiMessage.clientId);
      } else if (apiMessage is ApiIsoltePressButtonMessage) {
        response = repo.pressButton(apiMessage.componentId, apiMessage.clientId);
      } else if (apiMessage is ApiIsolateSetValueMessage) {
        response = repo.setValue(
            apiMessage.clientId, apiMessage.componentId, apiMessage.value);
      } else if (apiMessage is ApiIsolateDownloadImagesMessage) {
        var res = repo.downloadImages(clientId: apiMessage.clientId);
        var actions = await cont.processImageDownload(
          appName: apiMessage.appName,
          appVersion: apiMessage.appVersion,
          baseDir: apiMessage.baseDir,
          response: res
        );

        apiMessage.sendResponse(response: actions, sendPort: message.sendPort);
      } else if (apiMessage is ApiIsolateSetValuesMessage) {
        response = repo.setValues(
            clientId: apiMessage.setValuesRequest.clientId,
            componentId: apiMessage.setValuesRequest.componentId,
            columnNames: apiMessage.setValuesRequest.columnNames,
            values: apiMessage.setValuesRequest.values,
            dataProvider: apiMessage.setValuesRequest.dataProvider);
      } else if (apiMessage is ApiIsolateCloseTabMessage) {
        response = repo.tabClose(
            clientId: apiMessage.tabCloseRequest.clientId,
            componentName: apiMessage.tabCloseRequest.componentName,
            index: apiMessage.tabCloseRequest.index
        );
      }
      if (response != null) {
        var actions = await cont.processResponse(response);
        apiMessage.sendResponse(response: actions, sendPort: message.sendPort);
      }
    }
  });
}
