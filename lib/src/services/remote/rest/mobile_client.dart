import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as prefHttp;
import 'package:http/io_client.dart';

import 'http_client.dart';

class MobileClient implements HttpClient {
  prefHttp.Client client;

  MobileClient()
      : client = IOClient(
            io.HttpClient()..badCertificateCallback = _certificateCheck);

  static bool _certificateCheck(
          io.X509Certificate cert, String host, int port) =>
      true;

  @override
  void close() {
    client.close();
  }

  @override
  Future<prefHttp.Response> post(url,
      {Map<String, String>? headers, body, Encoding? encoding}) {
    return client.post(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<prefHttp.Response> get(url, {Map<String, String>? headers}) {
    return client.get(url, headers: headers);
  }

  void setWithCredentials(bool withCredentials) {
    // not needed, also not possible
  }
}

HttpClient getHttpClient() => MobileClient();
