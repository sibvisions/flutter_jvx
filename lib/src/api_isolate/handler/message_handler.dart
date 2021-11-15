import 'dart:isolate';


import 'package:flutter_jvx/src/api_isolate/i_api_isolate_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/controller_change_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/repository_change_message.dart';
import 'package:flutter_jvx/src/api_isolate/response/api_isolate_response.dart';
import 'package:flutter_jvx/src/api_isolate/response/result_message.dart';
import 'package:flutter_jvx/src/services/api/i_controller.dart';
import 'package:flutter_jvx/src/services/api/i_repository.dart';



class MessageHandler {

  IController? controller;
  IRepository? repository;

  receivedMessage(dynamic message) {
    var localController = controller;
    var localRepository = repository;
    var localMessage = message;



    if(message is RepositoryChangeMessage){
      repository = message.newRepository;
      sendResponse(message.sendPort, [ResultMessage(
          success: true,
          message: "The Repository was added",
          id: message.messageId
      )]);
    } else if(message is ControllerChangeMessage) {
      sendResponse(message.sendPort, [ResultMessage(
          success: true,
          message: "The Controller was added",
          id: message.messageId
      )]);
      controller = message.newController;
    } else if(message is ApiIsolateMessage) {
      sendResponse(message.sendPort, [ResultMessage(
          success: false,
          message: "type of Message was not found",
          id: message.messageId
      )]);
    }
  }

  ///
  /// Sends the [response] to the [sendPort].
  ///
  sendResponse(SendPort sendPort, List<ApiIsolateResponse> response) {
    sendPort.send(response);
  }
}