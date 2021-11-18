import 'package:http/http.dart';

abstract class IRepository {

  String appName = "demo";
  String? getClientId();
  void setClientId(String clientId);

  Future<Response> startUp();
  Future<Response> login(String username, String password);
  Future<Response> openScreen(String componentId);
}