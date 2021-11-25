import 'package:http/http.dart';

abstract class IRepository {
  Future<Response> startUp(String appName);
  Future<Response> login(String userName, String password, String clientId);
  Future<Response> openScreen(String componentId, String clientId);
  Future<Response> deviceStatus(String clientId, double screenWidth, double screenHeight);
}