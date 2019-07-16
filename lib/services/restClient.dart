import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestClient {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<MappedNetworkServiceResponse<T>> getAsync<T>(String resourcePath) async {
    var response = await http.get('http://172.16.0.19:8080/JVx.mobile/services/mobile' + resourcePath, headers: headers);
    updateCookie(response);
    return processResponse<T>(response);
  }

  Future<MappedNetworkServiceResponse<T>> postAsync<T>(String resourcePath, dynamic data) async {
    var content = json.encode(data);
    print(content);
    var response = await http.post('http://172.16.0.19:8080/JVx.mobile/services/mobile' + resourcePath, body: content, headers: headers);
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
      // headers['Content-Type'] = 'application/json';
      headers['cookie'] =
        (index == -1) ? rawCookie : rawCookie.substring(0, index);
      // globals.jsessionId = headers['cookie'];
    }
  }
}