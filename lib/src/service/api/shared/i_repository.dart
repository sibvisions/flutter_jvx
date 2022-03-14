import 'package:http/http.dart';

/// The interface declaring all possible requests to the mobile server.
abstract class IRepository {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<Response> startUp(String appName);
  Future<Response> login(String userName, String password, String clientId);
  Future<Response> openScreen(String componentId, String clientId);
  Future<Response> deviceStatus(String clientId, double screenWidth, double screenHeight);
  Future<Response> pressButton(String componentId, String clientId);
  Future<Response> setValue(String clientId, String componentId, dynamic value);
  Future<Response> downloadImages({
    required String clientId,
  });
  Future<Response> setValues({
    required String clientId,
    required String componentId,
    required List<String> columnNames,
    required List<dynamic> values,
    required String dataProvider,
  });
  Future<Response> tabClose({required String clientId, required String componentName, required int index});
}
