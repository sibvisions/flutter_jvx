import 'dart:convert';

import '../../../../model/api/requests/login_request.dart';
import '../../../../model/api/requests/open_screen_request.dart';
import '../../../../model/api/requests/startup_request.dart';
import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';
import 'package:http/http.dart';

class OnlineApiRepository implements IRepository {

  final ApiConfig apiConfig;
  final Client client = Client();
  final Map<String, String> _headers = {};

  OnlineApiRepository({
    required this.apiConfig,
  });


  Future<Response> _sendPostRequest(Uri uri, String body){
    Future<Response> res = client.post(uri, headers: _headers, body: body);
    res.then(_extractCookie);
    return res;
  }

  void _extractCookie(Response res) {
    String? rawCookie = res.headers["set-cookie"];
    if (rawCookie != null) {
      String cookie = rawCookie.substring(0, rawCookie.indexOf(";"));
      _headers.putIfAbsent("Cookie", () => cookie);
      if(_headers.containsKey("Cookie")){
        _headers.update("Cookie", (value) => cookie);
      }
    }
  }

  @override
  Future<Response> login(String userName, String password, String clientId) {
    LoginRequest request = LoginRequest(username: userName, password: password, clientId: clientId);
    return _sendPostRequest(apiConfig.getLoginUri(), jsonEncode(request));
  }

  @override
  Future<Response> startUp(String appName) {
    StartUpRequest startUpRequest = StartUpRequest(
        deviceMode: "mobile",
        applicationName: appName
    );
    return _sendPostRequest(apiConfig.getStartupUri(), jsonEncode(startUpRequest));
  }

  @override
  Future<Response> openScreen(String componentId, String clientId) {
    OpenScreenRequest openScreenRequest = OpenScreenRequest(
        manualClose: false,
        componentId: componentId,
        clientId: clientId,
    );
    return _sendPostRequest(apiConfig.getOpenScreenUri(), jsonEncode(openScreenRequest));

  }


}