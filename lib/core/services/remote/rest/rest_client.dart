import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../../models/api/request/upload.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/download_response.dart';
import '../../../models/api/response/error_response.dart';
import 'http_client.dart';

class RestClient {
  final HttpClient _client;

  final Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json',
  };

  RestClient(this._client) {
    this._client.setWithCredentials(true);
  }

  Future<Response> post(String path, dynamic data) async {
    final content = json.encode(data);

    var response;

    Response finalResponse;

    try {
      response = await this
          ._client
          .post(path, body: content, headers: headers)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      finalResponse = Response()
        ..error = ErrorResponse(
            'Timeout Error',
            'Timeout Error',
            'Couldn\'t connect to the server!',
            'timeout.error');
    } on Exception {
      finalResponse = Response()
        ..error = ErrorResponse(
            'Error',
            'An Error occured',
            'An Error while sending the Request occured',
            'message.error');
    }

    if (response == null || (response as http.Response).statusCode != 200) {
      finalResponse = Response()
        ..error = ErrorResponse(
            'Error',
            'An Error occured',
            response != null ? this.utf8convert(response.body) : '',
            'message.error');
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
        finalResponse = Response()
          ..error = ErrorResponse('Error', 'An Error occured',
              'Couldn\t decode response body', 'message.error');
      }
    }

    updateCookie(response);
    return finalResponse;
  }

  Future<Response> download(
      String path, dynamic data, String downloadFileName) async {
    var content = json.encode(data);
    var response;

    Response returnResponse = Response();

    try {
      response = await this
          ._client
          .post(path, body: content, headers: headers)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print(e);
    }

    if (response != null && response.bodyBytes != null) {
      returnResponse.downloadResponse =
          DownloadResponse('', response.bodyBytes);
    }
    
    if (response != null && data['name'] == 'file') {
      if (kIsWeb) {
        returnResponse.downloadResponse.fileName = downloadFileName;
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

    updateCookie(response);
    return returnResponse;
  }

  Future<Response> upload(String path, Upload upload) async {
    var response;
    Response resp = Response();

    try {
      var stream =
          new http.ByteStream(DelegatingStream(upload.file.openRead()).cast());
      var length = await upload.file.length();

      var uri = Uri.parse(path);

      var request = new http.MultipartRequest("POST", uri);

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

      response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 10));
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

      try {
        if (decodedBody is List) {
          resp = Response.fromJson(decodedBody);
        } else {
          resp = Response.fromJson([decodedBody]);
        }
      } catch (e) {
        return Response()
          ..error = ErrorResponse(
              'Error', 'An error occured.', '${e.toString()}', 'error');
      }
    }

    updateCookie(response);
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
    if (response != null) {
      String rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        int index = rawCookie.indexOf(';');
        headers['cookie'] =
            (index == -1) ? rawCookie : rawCookie.substring(0, index);
      }
    }
  }
}

// import 'dart:async';

// import 'dart:convert';
// import 'package:http/http.dart' as prefHttp;
// import 'package:jvx_flutterclient/core/models/api/response.dart';
// import 'package:jvx_flutterclient/core/models/api/response/download_response.dart';
// import 'package:path/path.dart';
// import 'package:async/async.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'http_client.dart';

// class RestClient {
//   bool debug = false;

//   HttpClient http;

//   Map<String, String> headers = {
//     'Content-Type': 'application/json'
//   };

//   Future get(String resourcePath) async {
//     http = HttpClient();
//     http.setWithCredentials(true);

//     var response = await http.get(resourcePath, headers: headers);
//     http.close();
//     updateCookie(response);
//     if (debug) {
//       // Log.printLong("Response: ${response.body}");
//     }

//     String body = this.utf8convert(response.body);
//     return body;
//   }

//   Future post(String resourcePath, dynamic data) async {
//     http = HttpClient();
//     http.setWithCredentials(true);

//     var content = json.encode(data);
//     var response;

//     try {
//       response = await http.post(resourcePath,
//           body: content,
//           headers: headers);
//     } catch (e) {}

//     http.close();

//     updateCookie(response);

//     if (debug) {
//       // Log.printLong("Request: $content");
//       // Log.printLong('Response: ${response.body}');
//     }

//     String body = this.utf8convert(response.body);
//     return body;
//   }

//   Future<Response> postAsync(String resourcePath, dynamic data) async {
//     http = HttpClient();
//     http.setWithCredentials(true);

//     var content = json.encode(data);
//     var response;

//     Response resp;
//     try {
//       response = await http.post(resourcePath,
//           body: content,
//           headers: headers).timeout(const Duration(seconds: 10));

//       if (debug) {
//         // Log.printLong("Request: $content");
//         // Log.printLong("Response: ${response.body}");
//       }

//       http.close();
//     } catch (e) {
//       http.close();
//       if (e is TimeoutException) {
//         // return Response()
//         //   ..title = 'Timeout Error'
//         //   ..errorName = 'timeout.error'
//         //   ..error = true
//         //   ..message = 'Timeout Error. Could not connect to the Server'
//         //   ..details = 'Timeout Exception was thrown';
//       }

//       // return Response()
//       //   ..title = 'Connection Error'
//       //   ..errorName = 'connection.error'
//       //   ..error = true
//       //   ..message = 'An error occured.';
//     }

//     if (response == null || (response as prefHttp.Response).statusCode != 200) {
//       // return Response()
//       //   ..title = 'Connection Error'
//       //   ..errorName = 'server.error'
//       //   ..error = true
//       //   ..message =
//       //       'An error with status code ${(response as prefHttp.Response).statusCode} occured.'
//       //   ..details =
//       //       '(${(response as prefHttp.Response).statusCode}): ${(response as prefHttp.Response).body}';
//     } else {
//       String body = this.utf8convert(response.body);
//       dynamic decodedBody = json.decode(body);
//       try {
//         if (decodedBody is List) {
//           resp = Response.fromJson(decodedBody);
//         } else {
//           resp = Response.fromJson([decodedBody]);
//         }
//       } catch (e) {
//         // if (e is ApiException) {
//         //   return Response()
//         //     ..details = e.details
//         //     ..message = e.message
//         //     ..title = e.title
//         //     ..errorName = e.name
//         //     ..error = true;
//         // } else {
//         //   return Response()
//         //     ..title = 'Error'
//         //     ..errorName = 'error'
//         //     ..error = true
//         //     ..message = 'An error occured.'
//         //     ..details = '${e.toString()}';
//         // }
//       }
//     }

//     if (debug) {
//       // Log.printLong("Request: $content");
//       // Log.printLong('Response: ${response.body}');
//     }

//     updateCookie(response);
//     return resp;
//   }

//   Future<Response> postAsyncDownload(String resourcePath, dynamic data) async {
//     http = HttpClient();
//     http.setWithCredentials(true);

//     var content = json.encode(data);
//     var response;
//     Response resp = Response();

//     response = await http.post(resourcePath,
//         body: content,
//         headers: headers);
//     http.close();
//     resp.downloadResponse = DownloadResponse(null, response.bodyBytes);

//     if (data['name'] == 'file') {
//       if (kIsWeb) {
//         resp.downloadResponse.fileName =

//       } else {
//         resp.downloadFileName = (response as prefHttp.Response)
//             .headers['content-disposition']
//             .split(' ')[1]
//             .substring(9);
//       }
//     }
//     try {} catch (e) {
//       return Response()
//         ..title = 'Connection Error'
//         ..errorName = 'connection.error'
//         ..error = true
//         ..message = 'An error occured.';
//     }

//     if (response == null || (response as prefHttp.Response).statusCode != 200) {
//       return Response()
//         ..title = 'Connection Error'
//         ..errorName = 'server.error'
//         ..error = true
//         ..message =
//             'An error with status code ${(response as prefHttp.Response).statusCode} occured.'
//         ..details =
//             '(${(response as prefHttp.Response).statusCode}): ${(response as prefHttp.Response).body}';
//     }

//     updateCookie(response);
//     return resp;
//   }

//   Future<Response> postAsyncUpload(String resourcePath, Upload data) async {
//     var response;
//     Response resp = Response();

//     try {
//       var stream =
//           new prefHttp.ByteStream(DelegatingStream.typed(data.file.openRead()));
//       var length = await data.file.length();

//       var uri = Uri.parse(globals.baseUrl + resourcePath);

//       var request = new prefHttp.MultipartRequest("POST", uri);

//       request.headers.addAll({'cookie': globals.jsessionId});

//       Map<String, String> formFields = {
//         'clientId': data.clientId,
//         'fileId': data.fileId
//       };

//       var multipartFile = new prefHttp.MultipartFile('data', stream, length,
//           filename: basename(data.file.path));

//       request.fields.addAll(formFields);
//       request.files.add(multipartFile);

//       final streamedResponse = await request.send();

//       response = await prefHttp.Response.fromStream(streamedResponse);
//     } catch (e) {
//       print('EXCEPTION: $e');

//       return Response()
//         ..title = 'Connection Error'
//         ..errorName = 'connection.error'
//         ..error = true
//         ..message = 'An error occured.';
//     }

//     if (response == null || (response as prefHttp.Response).statusCode != 200) {
//       return Response()
//         ..title = 'Connection Error'
//         ..errorName = 'server.error'
//         ..error = true
//         ..message =
//             'An error with status code ${(response as prefHttp.Response).statusCode} occured.'
//         ..details =
//             '(${(response as prefHttp.Response).statusCode}): ${(response as prefHttp.Response).body}';
//     } else {
//       dynamic decodedBody = json.decode(response.body);

//       print(decodedBody.toString());

//       try {
//         if (decodedBody is List) {
//           resp = Response.fromJson(decodedBody);
//         } else {
//           resp = Response.fromJsonForAppStyle(decodedBody);
//         }
//       } catch (e) {
//         if (e is ApiException) {
//           return Response()
//             ..details = e.details
//             ..message = e.message
//             ..title = e.title
//             ..errorName = e.name
//             ..error = true;
//         } else {
//           return Response()
//             ..title = 'Error'
//             ..errorName = 'error'
//             ..error = true
//             ..message = 'An error occured.'
//             ..details = '${e.toString()}';
//         }
//       }
//     }

//     updateCookie(response);
//     return resp;
//   }

//   void updateCookie(prefHttp.Response response) {
//     String rawCookie = response.headers['set-cookie'];
//     if (rawCookie != null) {
//       int index = rawCookie.indexOf(';');
//       headers['cookie'] =
//           (index == -1) ? rawCookie : rawCookie.substring(0, index);
//       globals.jsessionId = headers['cookie'];
//     }
//   }

//   String utf8convert(String text) {
//     try {
//       List<int> bytes = text.toString().codeUnits;
//       return utf8.decode(bytes);
//     } catch (e) {
//       print("Failed to decode string to utf-8!");
//       return text;
//     }
//   }
// }
