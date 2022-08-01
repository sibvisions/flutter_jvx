import 'dart:isolate';

import '../../../../model/api/request/i_api_request.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/config/api/api_config.dart';
import '../../../isolate/isolate_message.dart';
import '../../../isolate/isolate_message_wrapper.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';
import 'api_isolate_callback.dart';
import 'messages/api_isolate_api_config_message.dart';
import 'messages/api_isolate_controller_message.dart';
import 'messages/api_isolate_get_repository_message.dart';
import 'messages/api_isolate_request_message.dart';
import 'messages/api_isolate_set_repository_message.dart';

/// Executes [IApiRequest] in a separate isolate
class IsolateApiService implements IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// [IRepository] instance
  IRepository? repository;

  /// [IController] instance
  IController? controller;

  /// [Isolate] instance of the separate Isolate
  Isolate? _isolate;

  /// [SendPort] used to send & receive messages from the isolate.
  SendPort? _apiSendPort;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Future<IsolateApiService> create() async {
    IsolateApiService isolateApi = IsolateApiService();
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

  @override
  Future<IRepository> getRepository() async {
    var message = ApiIsolateGetRepositoryMessage();
    return await _sendRequest(pMessage: message);
  }

  @override
  Future<void> setRepository(IRepository pRepository) async {
    var message = ApiIsolateSetRepositoryMessage(repository: pRepository);
    await _sendRequest(pMessage: message);
  }

  @override
  Future<void> setController(IController pController) async {
    var message = ApiIsolateControllerMessage(controller: pController);
    await _sendRequest(pMessage: message);
  }

  @override
  void setApiConfig({required ApiConfig apiConfig}) {
    _sendRequest(pMessage: ApiIsolateApiConfigMessage(apiConfig: apiConfig));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends the [message] to the api isolate and returns a future containing the first answer.
  Future _sendRequest({required IsolateMessage pMessage}) async {
    SendPort? apiPort = _apiSendPort;
    if (apiPort != null) {
      // Response will come to this receivePort
      ReceivePort receivePort = ReceivePort();
      // Wrap message
      IsolateMessageWrapper wrapper = IsolateMessageWrapper(sendPort: receivePort.sendPort, message: pMessage);
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

    return true;
  }
}
