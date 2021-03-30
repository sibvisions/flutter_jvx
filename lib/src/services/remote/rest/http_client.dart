import 'dart:convert';
import 'package:http/http.dart';
import 'http_client_stub.dart'
    if (dart.library.io) 'mobile_client.dart'
    if (dart.library.html) 'browser_client.dart';

abstract class HttpClient {
  // some generic methods to be exposed.

  /// returns a value based on the key
  Future<Response> get(url, {Map<String, String>? headers});

  Future<Response> post(url,
      {Map<String, String>? headers, body, Encoding? encoding});

  void setWithCredentials(bool withCredentials) {}

  /// stores a key value pair in the respective storage.
  void close() {}

  /// factory constructor to return the correct implementation.
  factory HttpClient() => getHttpClient();
}
