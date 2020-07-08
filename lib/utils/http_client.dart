import 'dart:convert';
import 'package:http/http.dart';
import 'http_client_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) '../utils/mobile_client.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) '../utils/browser_client.dart';

abstract class HttpClient {
  // some generic methods to be exposed.

  /// returns a value based on the key
  Future<Response> get(url, {Map<String, String> headers}) {
    return null;
  }

  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    return null;
  }

  void setWithCredentials(bool withCredentials){}

  /// stores a key value pair in the respective storage.
  void close() {}

  /// factory constructor to return the correct implementation.
  factory HttpClient() => getHttpClient();
}
