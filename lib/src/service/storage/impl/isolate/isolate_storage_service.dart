import 'dart:isolate';

import '../../../../model/command/base_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../i_storage_service.dart';
import 'message/endpoint/storage_isolate_delete_screen_message.dart';
import 'message/endpoint/storage_isolate_get_screen_message.dart';
import 'message/endpoint/storage_isolate_update_components_message.dart';
import 'message/storage_isolate_message.dart';
import 'message/storage_isolate_message_wrapper.dart';
import 'storage_isolate_callback.dart';

class IsolateStorageService implements IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Future<IsolateStorageService> create() async {
    IsolateStorageService isolateStorageService = IsolateStorageService();

    await isolateStorageService.initStorageIsolate();

    return isolateStorageService;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// [Isolate] instance of the separate Isolate
  Isolate? _isolate;

  /// [SendPort] used to send & receive messages from the isolate.
  SendPort? _apiSendPort;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) async {
    StorageIsolateGetScreenMessage getScreenMessage = StorageIsolateGetScreenMessage(screenClassName: screenClassName);
    return await _sendMessage(getScreenMessage);
  }

  @override
  Future<List<BaseCommand>> updateComponents(
      List? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName) async {
    StorageIsolateUpdateComponentsMessage updateComponentsMessage = StorageIsolateUpdateComponentsMessage(
        componentsToUpdate: componentsToUpdate, newComponents: newComponents, screenClassName: screenName);
    return await _sendMessage(updateComponentsMessage);
  }

  @override
  Future<void> deleteScreen({required String screenName}) async {
    StorageIsolateDeleteScreenMessage deleteScreenMessage = StorageIsolateDeleteScreenMessage(screenName: screenName);
    return await _sendMessage(deleteScreenMessage);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends the [message] to the api Isolate and returns a Future containing the first answer.
  Future _sendMessage(StorageIsolateMessage message) async {
    //TODO fix async awaits and remove every wrapper message and co&kg
    SendPort? apiPort = _apiSendPort;
    if (apiPort != null) {
      // Response will come to this receivePort
      ReceivePort receivePort = ReceivePort();
      // Wrap message
      StorageIsolateMessageWrapper wrapper =
          StorageIsolateMessageWrapper(sendPort: receivePort.sendPort, message: message);
      // send message to isolate
      apiPort.send(wrapper);
      // Needs to be casted, response type is assured by message itself (sendResponse method)
      return receivePort.first;
    } else {
      throw Exception("SendPort to Storage Isolate was null, could not send request");
    }
  }

  Future<bool> initStorageIsolate() async {
    // Local and temporary ReceivePort to retrieve the new isolate's SendPort
    ReceivePort receivePort = ReceivePort();

    // Spawn isolate
    _isolate = await Isolate.spawn(storageCallback, receivePort.sendPort);

    // Retrieve the port to be used for further communication
    _apiSendPort = await receivePort.first;

    return true;
  }
}
