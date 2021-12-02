import 'dart:isolate';

import 'package:flutter/material.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/menu/menu_model.dart';
import '../../i_storage_service.dart';
import 'message/endpoint/storage_isolate_get_menu_message.dart';
import 'message/endpoint/storage_isolate_get_screen_message.dart';
import 'message/endpoint/storage_isolate_save_menu_message.dart';
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
  Future<MenuModel> getMenu() async {
    StorageIsolateGetMenuMessage getMenuMessage = StorageIsolateGetMenuMessage();
    return await _sendMessage(getMenuMessage);
  }

  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) async {
    StorageIsolateGetScreenMessage getScreenMessage = StorageIsolateGetScreenMessage(screenClassName: screenClassName);
    return await _sendMessage(getScreenMessage);
  }

  @override
  Future<bool> saveMenu(MenuModel menuModel) async {
    StorageIsolateSaveMenuMessage saveMenuMessage = StorageIsolateSaveMenuMessage(menuModel: menuModel);
    return await _sendMessage(saveMenuMessage);
  }

  @override
  Future<List<BaseCommand>> updateComponents(List? componentsToUpdate, List<FlComponentModel>? newComponents) async {
    StorageIsolateUpdateComponentsMessage updateComponentsMessage = StorageIsolateUpdateComponentsMessage(componentsToUpdate: componentsToUpdate, newComponents: newComponents);
    return await _sendMessage(updateComponentsMessage);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends the [message] to the api Isolate and returns a Future containing the first answer.
  Future _sendMessage(StorageIsolateMessage message) async {
    SendPort? apiPort = _apiSendPort;
    if(apiPort != null){
      // Response will come to this receivePort
      ReceivePort receivePort = ReceivePort();
      // Wrap message
      StorageIsolateMessageWrapper wrapper = StorageIsolateMessageWrapper(sendPort: receivePort.sendPort, message: message);
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