import 'package:archive/archive.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/log.dart';

class RestClient {
  bool debug = false;

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<MappedNetworkServiceResponse<T>> getAsync<T>(
      String resourcePath) async {
    var response = await http.get(globals.baseUrl + resourcePath, headers: {
      'Content-Type': 'application/json',
      'cookie': globals.jsessionId
    });
    updateCookie(response);
    if (debug) {
      Log.printLong("Response:" + response.body);
    }
  }

  Future get(String resourcePath) async {
    var response = await http.get(globals.baseUrl + resourcePath, headers: {
      'Content-Type': 'application/json',
      'cookie': globals.jsessionId
    });
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
      response = await http.Client().post(globals.baseUrl + resourcePath,
          body: content,
          headers: {
            'Content-Type': 'application/json',
            'cookie': globals.jsessionId
          });
    } catch (e) {}

    updateCookie(response);

    if (debug) {
      Log.printLong('Response: ${response.body}');
    }

    return response.body;
  }

  Future<Response> postAsync(String resourcePath, dynamic data) async {
    var content = json.encode(data);
    var response;
    
    Response resp;
    try {
      response = await http.Client().post(globals.baseUrl + resourcePath,
          body: content,
          headers: {
            'Content-Type': 'application/json',
            'cookie': globals.jsessionId
          });
    } catch (e) {
      return Response()
        ..error = true
        ..message = 'Could not connect to server!';
    }

    if (response == null || (response as http.Response).statusCode != 200) {
      return Response.fromJson(json.decode(response.body));
    } else {
      resp = Response.fromJson(json.decode(response.body));
    }

    updateCookie(response);
    return resp;
  }

  Future<Response> postAsyncDownload(
      String resourcePath, dynamic data) async {
    var content = json.encode(data);
    var response;
    Response resp = Response();
    try {
      response = await http.Client().post(
          globals.baseUrl + resourcePath,
          body: content,
          headers: {
            'Content-Type': 'application/json',
            'cookie': globals.jsessionId
          });

      resp.download = response.bodyBytes;
    } catch (e) {
      resp = Response()
        ..error = true
        ..message = 'Error';
    }
    updateCookie(response);
    return resp;
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
