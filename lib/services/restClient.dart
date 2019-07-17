import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class RestClient {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<MappedNetworkServiceResponse<T>> getAsync<T>(String resourcePath) async {
    var response = await http.get(globals.baseUrl + resourcePath, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    updateCookie(response);
    return processResponse<T>(response);
  }

  Future<MappedNetworkServiceResponse<T>> postAsync<T>(String resourcePath, dynamic data) async {
    var content = json.encode(data);
    var response = await http.post(globals.baseUrl + resourcePath, body: content, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    updateCookie(response);
    return processResponse<T>(response);
  }

  MappedNetworkServiceResponse<T> processResponse<T>(http.Response response) {
    if (!((response.statusCode < 200) || response.statusCode >= 300 || (response.body == null))) {
      var jsonResult = response.body;
      dynamic resultClass = jsonDecode(jsonResult);

      return new MappedNetworkServiceResponse<T>(
        mappedResult: resultClass,
        networkServiceResponse: new NetworkServiceResponse<T>(success: true)
      );
    } else {
      var errorResponse = response.body;
      return new MappedNetworkServiceResponse<T>(
        networkServiceResponse: new NetworkServiceResponse<T>(
          success: false,
          message: "(${response.statusCode}) ${errorResponse.toString()}"
        )
      );
    }
  }

    void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
        (index == -1) ? rawCookie : rawCookie.substring(0, index);
      globals.jsessionId = headers['cookie'];
    }
  }
}