import 'dart:isolate';

import '../../../../model/command/base_command.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';
import 'api_isolate_callback.dart';
import 'messages/api_isolate_controller_message.dart';
import 'messages/api_isolate_message.dart';
import 'messages/api_isolate_message_wrapper.dart';
import 'messages/api_isolate_repository_message.dart';
import 'messages/endpoint/api_isolate_device_status_message.dart';
import 'messages/endpoint/api_isolate_login_message.dart';
import 'messages/endpoint/api_isolate_open_screen_message.dart';
import 'messages/endpoint/api_isolate_press_button_message.dart';
import 'messages/endpoint/api_isolate_startup_message.dart';

/// Makes Request to JVx Mobile API and parses responses to [BaseCommand]
// Author: Michael Schober
class IsolateApi implements IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  IsolateApi({
    required this.controller,
    required this.repository,
  });

  static Future<IsolateApi> create({required IController controller, required IRepository repository}) async {
    IsolateApi isolateApi = IsolateApi(controller: controller, repository: repository);
    await isolateApi.initApiIsolate();
    return isolateApi;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// [IRepository] instance
  IRepository repository;

  /// [IController] instance
  IController controller;

  /// [Isolate] instance of the separate Isolate
  Isolate? _isolate;

  /// [SendPort] used to send & receive messages from the isolate.
  SendPort? _apiSendPort;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> deviceStatus(String clientId, double screenWidth, double screenHeight) async {
    ApiIsolateDeviceStatusMessage deviceStatusMessage =
        ApiIsolateDeviceStatusMessage(screenHeight: screenHeight, screenWidth: screenWidth, clientId: clientId);
    return await _sendRequest(deviceStatusMessage);
  }

  @override
  Future<List<BaseCommand>> login(String username, String password, String clientId) async {
    return await _sendRequest(ApiIsolateLoginMessage(userName: username, password: password, clientId: clientId));
  }

  @override
  Future<List<BaseCommand>> openScreen(String componentId, String clientId) async {
    ApiIsolateOpenScreenMessage openScreenMessage =
        ApiIsolateOpenScreenMessage(clientId: clientId, componentId: componentId);
    return await _sendRequest(openScreenMessage);
  }

  @override
  Future<List<BaseCommand>> startUp(String appName) async {
    return await _sendRequest(ApiIsolateStartUpMessage(appName: appName));
  }

  @override
  Future<List<BaseCommand>> pressButton(String clientId, String componentId) async {
    return await _sendRequest(ApiIsoltePressButtonMessage(clientId: clientId, componentId: componentId));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends the [message] to the api Isolate and returns a Future containing the first answer.
  Future _sendRequest(ApiIsolateMessage message) async {
    SendPort? apiPort = _apiSendPort;
    if (apiPort != null) {
      // Response will come to this receivePort
      ReceivePort receivePort = ReceivePort();
      // Wrap message
      ApiIsolateMessageWrapper wrapper = ApiIsolateMessageWrapper(sendPort: receivePort.sendPort, message: message);
      // send message to isolate
      apiPort.send(wrapper);
      // Needs to be casted, response type is assured by message itself (sendResponse method)
      return receivePort.first;
    } else {
      throw Exception("SendPort to Api Isolate was null, could not send request");
    }
  }

  Future<bool> initApiIsolate() async {
    // Local and temporary ReceivePort to retrieve the new isolate's SendPort
    ReceivePort receivePort = ReceivePort();

    // Spawn isolate
    _isolate = await Isolate.spawn(apiCallback, receivePort.sendPort);

    // Retrieve the port to be used for further communication
    _apiSendPort = await receivePort.first;

    // init. controller & repository
    SendPort? apiSendPort = _apiSendPort;
    if (apiSendPort != null) {
      ApiIsolateRepositoryMessage repositoryMessage = ApiIsolateRepositoryMessage(repository: repository);
      ApiIsolateControllerMessage controllerMessage = ApiIsolateControllerMessage(controller: controller);

      ApiIsolateMessageWrapper repositoryWrapper =
          ApiIsolateMessageWrapper(sendPort: apiSendPort, message: repositoryMessage);
      ApiIsolateMessageWrapper controllerWrapper =
          ApiIsolateMessageWrapper(sendPort: apiSendPort, message: controllerMessage);

      apiSendPort.send(repositoryWrapper);
      apiSendPort.send(controllerWrapper);
    }
    return true;
  }
}
