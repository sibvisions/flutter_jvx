import 'dart:convert';

import 'package:http/src/response.dart';
import 'package:http/http.dart' as prefHttp;

import '../utils/http_client.dart';

class MobileClient implements HttpClient {
  prefHttp.Client client = prefHttp.Client();

  @override
  void close() {
    client.close();
  }

  @override
  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    return client.post(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> get(url, {Map<String, String> headers}) {
    return client.get(url, headers: headers);
  }

  void setWithCredentials(bool withCredentials) {
    // not needed, also not possible
  }
}

HttpClient getHttpClient() => MobileClient();
