import 'dart:async';

import '../utils/shared_preferences_helper.dart';
import '../model/api/exceptions/api_exception.dart';
import '../model/api/request/upload.dart';
import '../model/api/response/response.dart';
import 'dart:convert';
import 'package:http/http.dart' as prefHttp;
import '../utils/globals.dart' as globals;
import '../utils/log.dart';
import '../utils/http_client.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RestClient {
  bool debug = false;

  HttpClient http;

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future get(String resourcePath) async {
    http = HttpClient();
    http.setWithCredentials(true);

    var response = await http.get(globals.baseUrl + resourcePath, headers: {
      'Content-Type': 'application/json',
      'cookie': globals.jsessionId
    });
    http.close();
    updateCookie(response);
    if (debug) {
      Log.printLong("Response: ${response.body}");
    }

    String body = this.utf8convert(response.body);
    return body;
  }

  Future post(String resourcePath, dynamic data) async {
    http = HttpClient();
    http.setWithCredentials(true);

    var content = json.encode(data);
    var response;

    try {
      response = await http.post(globals.baseUrl + resourcePath,
          body: content,
          headers: {
            'Content-Type': 'application/json',
            'cookie': globals.jsessionId
          });
    } catch (e) {}

    http.close();

    updateCookie(response);

    if (debug) {
      Log.printLong("Request: $content");
      Log.printLong('Response: ${response.body}');
    }

    String body = this.utf8convert(response.body);
    return body;
  }

  Future<Response> postAsync(String resourcePath, dynamic data) async {
    http = HttpClient();
    http.setWithCredentials(true);

    var content = json.encode(data);
    var response;

    Response resp;
    try {
      response = await http.post(globals.baseUrl + resourcePath,
          body: content,
          headers: {
            'Content-Type': 'application/json',
            'cookie': globals.jsessionId
          }).timeout(const Duration(seconds: 10));

      http.close();
    } catch (e) {
      http.close();
      if (e is TimeoutException) {
        return Response()
          ..title = 'Timeout Error'
          ..errorName = 'timeout.error'
          ..error = true
          ..message = 'Timeout Error. Could not connect to the Server'
          ..details = 'Timeout Exception was thrown';
      }

      return Response()
        ..title = 'Connection Error'
        ..errorName = 'connection.error'
        ..error = true
        ..message = 'An error occured.';
    }

    if (response == null || (response as prefHttp.Response).statusCode != 200) {
      return Response()
        ..title = 'Connection Error'
        ..errorName = 'server.error'
        ..error = true
        ..message =
            'An error with status code ${(response as prefHttp.Response).statusCode} occured.'
        ..details =
            '(${(response as prefHttp.Response).statusCode}): ${(response as prefHttp.Response).body}';
    } else {
      String body = this.utf8convert(response.body);
      dynamic decodedBody = json.decode(body);
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
      Log.printLong("Request: $content");
      Log.printLong('Response: ${response.body}');
    }

    updateCookie(response);
    return resp;
  }

  Future<Response> postAsyncDownload(String resourcePath, dynamic data) async {
    http = HttpClient();
    http.setWithCredentials(true);

    var content = json.encode(data);
    var response;
    Response resp = Response();

    response = await http.post(globals.baseUrl + resourcePath,
        body: content,
        headers: {
          'Content-Type': 'application/json',
          'cookie': globals.jsessionId
        });
    http.close();
    resp.download = response.bodyBytes;
    resp.error = false;

    if (data['name'] == 'file') {
      if (kIsWeb) {
        resp.downloadFileName =
            await SharedPreferencesHelper().getDownloadFileName();
      } else {
        resp.downloadFileName = (response as prefHttp.Response)
            .headers['content-disposition']
            .split(' ')[1]
            .substring(9);
      }
    }
    try {} catch (e) {
      return Response()
        ..title = 'Connection Error'
        ..errorName = 'connection.error'
        ..error = true
        ..message = 'An error occured.';
    }

    if (response == null || (response as prefHttp.Response).statusCode != 200) {
      return Response()
        ..title = 'Connection Error'
        ..errorName = 'server.error'
        ..error = true
        ..message =
            'An error with status code ${(response as prefHttp.Response).statusCode} occured.'
        ..details =
            '(${(response as prefHttp.Response).statusCode}): ${(response as prefHttp.Response).body}';
    }

    updateCookie(response);
    return resp;
  }

  Future<Response> postAsyncUpload(String resourcePath, Upload data) async {
    var response;
    Response resp = Response();

    try {
      var stream =
          new prefHttp.ByteStream(DelegatingStream.typed(data.file.openRead()));
      var length = await data.file.length();

      var uri = Uri.parse(globals.baseUrl + resourcePath);

      var request = new prefHttp.MultipartRequest("POST", uri);

      request.headers.addAll({'cookie': globals.jsessionId});

      Map<String, String> formFields = {
        'clientId': data.clientId,
        'fileId': data.fileId
      };

      var multipartFile = new prefHttp.MultipartFile('data', stream, length,
          filename: basename(data.file.path));

      request.fields.addAll(formFields);
      request.files.add(multipartFile);

      final streamedResponse = await request.send();

      response = await prefHttp.Response.fromStream(streamedResponse);
    } catch (e) {
      print('EXCEPTION: $e');

      return Response()
        ..title = 'Connection Error'
        ..errorName = 'connection.error'
        ..error = true
        ..message = 'An error occured.';
    }

    if (response == null || (response as prefHttp.Response).statusCode != 200) {
      return Response()
        ..title = 'Connection Error'
        ..errorName = 'server.error'
        ..error = true
        ..message =
            'An error with status code ${(response as prefHttp.Response).statusCode} occured.'
        ..details =
            '(${(response as prefHttp.Response).statusCode}): ${(response as prefHttp.Response).body}';
    } else {
      dynamic decodedBody = json.decode(response.body);

      print(decodedBody.toString());

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

    updateCookie(response);
    return resp;
  }

  void updateCookie(prefHttp.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
      globals.jsessionId = headers['cookie'];
    }
  }

  String utf8convert(String text) {
    try {
      List<int> bytes = text.toString().codeUnits;
      return utf8.decode(bytes);
    } catch (e) {
      print("Failed to decode string to utf-8!");
      return text;
    }
  }
}
