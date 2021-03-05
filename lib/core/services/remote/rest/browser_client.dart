import 'dart:convert';

import 'package:http/browser_client.dart' as bc;
import 'package:http/http.dart';

import 'http_client.dart';

class BrowserClient implements HttpClient {
  bc.BrowserClient client = bc.BrowserClient();

  @override
  void close() {
    client.close();
  }

  @override
  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) {
    return client.post(Uri.parse(url),
        headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<Response> get(url, {Map<String, String> headers}) {
    return client.get(Uri.parse(url), headers: headers);
  }

  void setWithCredentials(bool withCredentials) {
    client.withCredentials = withCredentials;
  }
}

HttpClient getHttpClient() => BrowserClient();
