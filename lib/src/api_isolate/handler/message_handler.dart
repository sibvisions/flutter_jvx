import 'dart:developer';
import 'dart:isolate';


import 'package:flutter_jvx/src/api_isolate/request/app_name_change_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/controller_change_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/open_screen_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/repository_change_message.dart';
import 'package:flutter_jvx/src/api_isolate/request/startup_message.dart';
import 'package:flutter_jvx/src/api_isolate/response/api_isolate_response.dart';
import 'package:flutter_jvx/src/models/api/action/meta_action.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/services/api/i_controller.dart';
import 'package:flutter_jvx/src/services/api/i_repository.dart';
import 'package:http/http.dart';



class MessageHandler {

  IController? controller;
  IRepository? repository;

  receivedMessage(dynamic message) {
    var localController = controller;
    var localRepository = repository;
    dynamic messageCopy = null;

    //Setup Messages
    if(message is RepositoryChangeMessage){
        repository = message.newRepository;
    } else if(message is ControllerChangeMessage) {
        controller = message.newController;
    } else if(message is AppNameChangeMessage && localRepository != null) {
        localRepository.appName = message.appName;
    }

    //Remote Requests
    if(localRepository != null && localController != null){
      Future<Response>? request;

      if(message is StartupMessage){
        request = localRepository.startUp();
        messageCopy = StartupMessage.from(message);
      } else if(message is OpenScreenMessage) {
        request = localRepository.openScreen(message.componentId);
        messageCopy = OpenScreenMessage.from(message);
      }

      if(request != null && messageCopy != null) {
        Future<List<ProcessorAction>> actions = localController.determineResponse(request);
        actions.then((value) {
          //Check for ClientID
          int index = value.indexWhere((element) => element is MetaAction);
          if(index != -1){
            MetaAction metaAction = (value[index] as MetaAction);
            localRepository.setClientId(metaAction.clientId);
          }


          ApiIsolateResponse response = ApiIsolateResponse(
            id: "id",
            actions: value,
            initialMessage: messageCopy
          );
          _sendResponse(messageCopy.sendPort, response);
        });
      }
    }
  }

  ///
  /// Sends the [response] to the [sendPort].
  ///
  _sendResponse(SendPort sendPort, ApiIsolateResponse response) {
    sendPort.send(response);
  }
}