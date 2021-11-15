import 'dart:isolate';

import 'package:flutter/material.dart';

///
/// Used as a base Type for Communication with the API Isolate
///
abstract class ApiIsolateMessage {

  ///Id will be used to identify the response of the isolate
  final String messageId = DateTime.now().microsecondsSinceEpoch.toString();

  ///SendPort where results will be sent to;
  final SendPort sendPort;

  ApiIsolateMessage({required this.sendPort});

}