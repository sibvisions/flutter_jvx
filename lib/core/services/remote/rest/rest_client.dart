import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:universal_html/html.dart';

import '../../../models/api/request/upload.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/download_response.dart';
import '../../../models/api/response/error_response.dart';
import 'http_client.dart';

class RestClient {
  final HttpClient _client;

  RestClient(this._client) {
    this._client.setWithCredentials(true);
  }

  Future<Response> post(String path, dynamic data, String sessionId) async {
    final content = json.encode(data);

    var response;

    Response finalResponse;

    try {
      var headers;
      if (kIsWeb) {
        headers = <String, String>{
          'Content-Type': 'application/json',
        };
        document.cookie = sessionId;
      } else {
        headers = <String, String>{
          'Content-Type': 'application/json',
          'cookie': sessionId,
        };
      }

      response = await this
          ._client
          .post(path, body: content, headers: headers)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      finalResponse = Response()
        ..error = ErrorResponse(
            'Timeout Error',
            'Couldn\'t connect to the server!',
            'Timeout error',
            'timeout.error');
    } on Exception {
      finalResponse = Response();
    }

    if (response == null || (response as http.Response).statusCode != 200) {
      // print((response as http.Response).body);
      finalResponse = Response()
        ..error = ErrorResponse(
            'Error', 'An Error occured', 'An Error occured', 'message.error');
    } else {
      String body = this.utf8convert(response.body);
      dynamic decodedBody = json.decode(body);

      try {
        if (decodedBody is List) {
          finalResponse = Response.fromJson(decodedBody);
        } else {
          decodedBody['name'] = 'application.style';
          finalResponse = Response.fromJson([decodedBody]);
        }
      } on Exception {
        finalResponse = Response();
      }
    }

    if (response != null) {
      finalResponse.sessionId = updateCookie(response);
    }
    return finalResponse;
  }

  Future<Response> download(
      String path, dynamic data, String jsessionId) async {
    var content = json.encode(data);
    var response;

    Response returnResponse = Response();

    var headers;
    if (kIsWeb) {
      headers = <String, String>{
        'Content-Type': 'application/json',
      };
      document.cookie = jsessionId;
    } else {
      headers = <String, String>{
        'Content-Type': 'application/json',
        'cookie': jsessionId,
      };
    }

    response = await http.post(path, body: content, headers: headers);

    returnResponse.downloadResponse = DownloadResponse('', response.bodyBytes);

    if (data['name'] == 'file') {
      if (kIsWeb) {
      } else {
        returnResponse.downloadResponse.fileName = (response as http.Response)
            .headers['content-disposition']
            .split(' ')[1]
            .substring(9);
      }
    }

    if (response == null || (response as http.Response).statusCode != 200) {
      return Response()
        ..error = ErrorResponse(
            'Server Error',
            '(${(response as http.Response).statusCode}): ${(response as http.Response).body}',
            'An error with status code ${(response as http.Response).statusCode} occured.',
            'server.error');
    }

    return returnResponse;
  }

  Future<Response> upload(String path, Upload upload, String jsessionId) async {
    var response;
    Response resp = Response();

    try {
      var stream =
          new http.ByteStream(DelegatingStream(upload.file.openRead()).cast());
      var length = await upload.file.length();

      var uri = Uri.parse(path);

      var request = new http.MultipartRequest("POST", uri);

      var headers;
      if (kIsWeb) {
        headers = null;
        document.cookie = jsessionId;
      } else {
        headers = <String, String>{
          'Content-Type': 'application/json',
          'cookie': jsessionId,
        };
      }

      request.headers.addAll(headers);

      Map<String, String> formFields = {
        'clientId': upload.clientId,
        'fileId': upload.fileId
      };

      var multipartFile = new http.MultipartFile('data', stream, length,
          filename: basename(upload.file.path));

      request.fields.addAll(formFields);
      request.files.add(multipartFile);

      final streamedResponse = await request.send();

      response = await http.Response.fromStream(streamedResponse);
    } catch (e) {
      print('EXCEPTION: $e');

      return Response()
        ..error = ErrorResponse(
            'Connection Error', '', 'An error occured.', 'connection.error');
    }

    if (response == null || (response as http.Response).statusCode != 200) {
      return Response()
        ..error = ErrorResponse(
            'Connection Error',
            '(${(response as http.Response).statusCode}): ${(response as http.Response).body}',
            'An error with status code ${(response as http.Response).statusCode} occured.',
            'server.error');
    } else {
      dynamic decodedBody = json.decode(response.body);

      print(decodedBody.toString());

      try {
        if (decodedBody is List) {
          resp = Response.fromJson(decodedBody);
        } else {
          resp = Response.fromJson([decodedBody]);
        }
      } catch (e) {
        return Response()
          ..error = ErrorResponse(
              'Error', '${e.toString()}', 'An error occured.', 'error');
      }
    }

    resp.sessionId = updateCookie(response);
    return resp;
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

  updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      return (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    return null;
  }
}
