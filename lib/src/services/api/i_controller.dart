import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:http/http.dart';

abstract class IController {
  
  Future<List<ProcessorAction>> determineResponse(Future<Response> response);
}