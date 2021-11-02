import 'package:http/http.dart';

abstract class IController {
  
  void determineResponse(Future<Response> response);
}