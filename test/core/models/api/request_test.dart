import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_flutterclient/core/models/api/request.dart';
import 'package:jvx_flutterclient/core/models/api/request/login.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  final tRequest = Login(
    clientId: 'dwadwd-wdwad-adwdw-dwdwdd',
    createAuthKey: true,
    password: 'features',
    username: 'features',
    requestType: RequestType.LOGIN
  );

  group('toJson', () {
    test('should return a valid json', () async {
      final logindata = tRequest.toJson();

      expect(logindata, json.decode(fixture('login_request_cached.json')));
    });
  });
}