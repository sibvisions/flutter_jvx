import 'dart:convert';

import 'package:http/src/response.dart';
import 'package:http/browser_client.dart' as bc;

import '../utils/http_client.dart';

class BrowserClient implements HttpClient
{
  bc.BrowserClient client = bc.BrowserClient();

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

  void setWithCredentials(bool withCredentials){
    client.withCredentials = withCredentials;
  }
}

HttpClient getHttpClient() => BrowserClient();