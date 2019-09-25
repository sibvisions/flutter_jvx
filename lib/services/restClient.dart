import 'package:archive/archive.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/log.dart';

class RestClient {
  bool debug = true;

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<MappedNetworkServiceResponse<T>> getAsync<T>(String resourcePath) async {
    var response = await http.get(globals.baseUrl + resourcePath, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    updateCookie(response);
    if (debug) {
      Log.printLong("Response:"+ response.body);
    }

    return processResponse<T>(response);
  }

  Future get(String resourcePath) async {
    var response = await http.get(globals.baseUrl + resourcePath, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    updateCookie(response);
    if (debug) {
      Log.printLong("Response: ${response.body}");
    }

    return response.body;
  }

  Future post(String resourcePath, dynamic data) async {
    var content = json.encode(data);
    var response;

    try {
      response = await http.Client().post(globals.baseUrl + resourcePath, body: content, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    } catch (e) {}
    
    updateCookie(response);

    if (debug) {
      Log.printLong('Response: ${response.body}');
    }

    return response.body;
  }

  Future<MappedNetworkServiceResponse<T>> postAsync<T>(String resourcePath, dynamic data) async {
    var content = json.encode(data);
    var response;
    try {
      response = await http.Client()
        .post(globals.baseUrl + resourcePath, body: content, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    } catch (e) {
      return new MappedNetworkServiceResponse<T>(
        networkServiceResponse: new NetworkServiceResponse<T>(
          success: false,
          message: "Couldn't connect to Server"
        )
      );
    }
    updateCookie(response);

    if (debug) {
      Log.printLong("Response:"+ response.body);
    }

    return processResponse<T>(response);
  }

  Future<MappedNetworkServiceResponse<T>> postAsyncDownload<T>(String resourcePath, dynamic data) async {
    var content = json.encode(data);
    var response;
    try {
      response = await http.Client().post(Uri.parse(globals.baseUrl + resourcePath), body: content, headers: { 'Content-Type': 'application/json', 'cookie': globals.jsessionId });
    } catch (e) {
      return new MappedNetworkServiceResponse(
        networkServiceResponse: new NetworkServiceResponse(
          success: false,
          message: "Couldn't connect to Server"
        )
      );
    }
    updateCookie(response);
    return processFileResponse<T>(response);
  }

  MappedNetworkServiceResponse<T> processFileResponse<T>(http.Response response) {
    if (!((response.statusCode < 200) ||response.statusCode >= 300 || (response.body == null))) {
      var archive = ZipDecoder().decodeBytes(response.bodyBytes);

      return new MappedNetworkServiceResponse<T>(
        mappedResult: archive,
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