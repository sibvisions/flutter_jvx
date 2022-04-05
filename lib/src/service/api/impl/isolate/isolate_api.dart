import 'dart:isolate';

import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

import '../../../../model/command/base_command.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';
import 'api_isolate_callback.dart';
import 'messages/api_isolate_controller_message.dart';
import 'messages/api_isolate_message.dart';
import 'messages/api_isolate_message_wrapper.dart';
import 'messages/api_isolate_repository_message.dart';
import 'messages/api_isolate_request_message.dart';

/// Executes [IApiRequest] in a separate isolate
class IsolateApi implements IApiService {

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendRequest({required IApiRequest request}) async {

    ApiIsolateRequestMessage message = ApiIsolateRequestMessage(request: request);

    return await _sendRequest(pMessage: message);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends the [message] to the api isolate and returns a future containing the first answer.
  Future _sendRequest({required ApiIsolateMessage pMessage}) async {
    SendPort? apiPort = _apiSendPort;
    if (apiPort != null) {
      // Response will come to this receivePort
      ReceivePort receivePort = ReceivePort();
      // Wrap message
      ApiIsolateMessageWrapper wrapper = ApiIsolateMessageWrapper(sendPort: receivePort.sendPort, message: pMessage);
      // send message to isolate
      apiPort.send(wrapper);
      // Needs to be casted, response type is assured by message itself (sendResponse method)
      return receivePort.first;
    } else {
      throw Exception("SendPort to api isolate was null, could not send request");
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
