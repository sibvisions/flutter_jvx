import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'message/endpoint/layout_in_process_message.dart';
import 'message/endpoint/layout_valid_message.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/layout/layout_data.dart';
import '../../i_layout_service.dart';
import 'layout_isolate.dart';
import 'message/endpoint/mark_as_dirty_message.dart';
import 'message/endpoint/report_layout_message.dart';
import 'message/endpoint/report_preferred_size_message.dart';
import 'message/endpoint/set_screen_size_message.dart';
import 'message/layout_message.dart';
import 'message/layout_message_wrapper.dart';

class IsolateLayoutService implements ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Future<IsolateLayoutService> create() async {
    IsolateLayoutService isolateLayoutService = IsolateLayoutService();

    await isolateLayoutService.initLayoutService();

    return isolateLayoutService;
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
  Future<bool> markLayoutAsDirty({required String pComponentId}) {
    MarkAsDirtyMessage message = MarkAsDirtyMessage(id: pComponentId);
    return _sendMessage<bool>(message);
  }

  @override
  bool removeLayout({required String pComponentId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<BaseCommand>> reportLayout({required LayoutData pLayoutData}) {
    ReportLayoutMessage message = ReportLayoutMessage(layoutData: pLayoutData);
    return _sendMessage<List<BaseCommand>>(message);
  }

  @override
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData pLayoutData}) {
    ReportPreferredSizeMessage message = ReportPreferredSizeMessage(layoutData: pLayoutData);
    return _sendMessage<List<BaseCommand>>(message);
  }

  @override
  Future<List<BaseCommand>> setScreenSize({required String pScreenComponentId, required Size pSize}) {
    SetScreenSizeMessage message = SetScreenSizeMessage(componentId: pScreenComponentId, size: pSize);
    return _sendMessage<List<BaseCommand>>(message);
  }

  @override
  Future<bool> layoutInProcess() {
    LayoutInProcessMessage message = LayoutInProcessMessage();
    return _sendMessage<bool>(message);
  }

  @override
  Future<bool> isValid() {
    LayoutValidMessage message = LayoutValidMessage(set: false, value: false);
    return _sendMessage<bool>(message);
  }

  @override
  Future<bool> setValid({required bool isValid}) {
    LayoutValidMessage message = LayoutValidMessage(set: true, value: isValid);
    return _sendMessage<bool>(message);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends the [message] to the api Isolate and returns a Future containing the first answer.
  Future<T> _sendMessage<T>(LayoutMessage message) async {
    SendPort? apiPort = _apiSendPort;
    if (apiPort != null) {
      // Response will come to this receivePort
      ReceivePort receivePort = ReceivePort();
      // Wrap message
      LayoutMessageWrapper wrapper = LayoutMessageWrapper(sendPort: receivePort.sendPort, message: message);
      // send message to isolate
      apiPort.send(wrapper);
      // Needs to be casted, response type is assured by message itself (sendResponse method)
      return await receivePort.first;
    } else {
      throw Exception("SendPort to Storage Isolate was null, could not send request");
    }
  }

  Future<bool> initLayoutService() async {
    // Local and temporary ReceivePort to retrieve the new isolate's SendPort
    ReceivePort receivePort = ReceivePort();

    // Spawn isolate
    _isolate = await Isolate.spawn(layoutIsolate, receivePort.sendPort);

    // Retrieve the port to be used for further communication
    _apiSendPort = await receivePort.first;

    return true;
  }
}
