import 'package:archive/archive.dart';
import 'package:jvx_mobile_v3/model/api/exceptions/api_exception.dart';
import 'package:jvx_mobile_v3/model/api/exceptions/session_timeout_exception.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
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

    print('REQUEST: $content');
    
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
        ..title = 'Connection Error'
        ..errorName = 'connection.error'
        ..error = true
        ..message = 'An error with status code ${(response as http.Response).statusCode} occured.'
        ..details = '(${(response as http.Response).statusCode}): ${(response as http.Response).body}';
    }

    if (response == null || (response as http.Response).statusCode != 200) {
      return Response()
        ..title = 'Connection Error'
        ..errorName = 'server.error'
        ..error = true
        ..message = 'An error with status code ${(response as http.Response).statusCode} occured.'
        ..details = '(${(response as http.Response).statusCode}): ${(response as http.Response).body}';
    } else {
      dynamic decodedBody = json.decode(response.body);
      try {
         if (decodedBody is List) {
           resp = Response.fromJson(decodedBody);
         } else {
           resp = Response.fromJsonForAppStyle(decodedBody);
         }
      } catch (e) {
        if (e is ApiException) {
          return Response()
            ..details = e.details
            ..message = e.message
            ..title = e.title
            ..errorName = e.name
            ..error = true;
        } else {
          return Response()
            ..title = 'Error'
            ..errorName = 'error'
            ..error = true
            ..message = 'An error occured.'
            ..details = '${e.toString()}';
        }
      }
    }
    
    if (debug) {
      Log.printLong('Response: ${response.body}');
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
      resp.error = false;
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
