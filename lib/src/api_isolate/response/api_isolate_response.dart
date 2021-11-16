import 'package:flutter_jvx/src/api_isolate/i_api_isolate_message.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';

///
/// Base Class for all ApiIsolate Responses
///
class ApiIsolateResponse {

  ///InitialMessage
  final ApiIsolateMessage initialMessage;

  ///Id of the initial message;
  final String id;

  ///Set of actions to perform based on the initial request
  final List<ProcessorAction> actions;

  ApiIsolateResponse({
    required this.id,
    required this.actions,
    required this.initialMessage
  });
}