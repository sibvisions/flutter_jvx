import 'dart:convert';

import 'package:flutter_jvx/src/models/api/requests.dart';
import 'package:flutter_jvx/src/models/api/requests/login_requests.dart';
import 'package:flutter_jvx/src/models/api/requests/open_screen_request.dart';
import 'package:flutter_jvx/src/models/config/i_config_api.dart';
import 'package:flutter_jvx/src/services/api/i_repository.dart';
import 'package:flutter_jvx/src/util/mixin/service/config_app_service_mixin.dart';
import 'package:http/http.dart';

class JVxOnlineRepository with ConfigAppServiceMixin implements IRepository {

  final Client client = Client();
  final Map<String, String> _headers = {};
  final IConfigApi apiConfig;

  JVxOnlineRepository({required this.apiConfig});



  Future<Response> _sendPostRequest(Uri endpoint, String body){
    Future<Response> res = client.post(endpoint, headers: _headers, body: body);
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

  String _getClientId() {
    String? clientId = configAppService.clientId;
    if(clientId != null){
      return clientId;
    } else {
      throw Exception("NO CLIENT_ID FOUND");
    }
  }

  // ------------ REQUESTS ---------------

  @override
  Future<Response> startUp() {
    String appName =  configAppService.appName;
    StartUpRequest req = StartUpRequest(applicationName: appName, deviceMode: "desktop");

    return _sendPostRequest(apiConfig.getStartup(), jsonEncode(req));
  }

  @override
  Future<Response> login(String username, String password) {
    String clientId = _getClientId();
    LoginRequest req = LoginRequest(
        username: username,
        password: password,
        clientId: clientId
    );

    return _sendPostRequest(apiConfig.getLogin(), jsonEncode(req));
  }

  @override
  Future<Response> openScreen(String componentId) {
    String clientId = _getClientId();
    OpenScreenRequest req = OpenScreenRequest(
        clientId: clientId,
        componentId: componentId
    );
    return _sendPostRequest(apiConfig.getOpenScreen(), jsonEncode(req));
  }

}

class RemoteEndpoints {
  static const startup = "startup";
}