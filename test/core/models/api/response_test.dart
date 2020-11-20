import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/models/api/response_object.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  final tResponse =
      Response.fromJson(json.decode(fixture('startup_cached.json')));

  test(
      'loginItem, applicationMetaData and language should be subclasses of responseObject',
      () async {
    expect(tResponse.loginItem, isA<ResponseObject>());
    expect(tResponse.applicationMetaData, isA<ResponseObject>());
    expect(tResponse.language, isA<ResponseObject>());
  });

  group('fromJson', () {
    test('should return a valid model', () async {
      final List jsonList = json.decode(fixture('startup_cached.json'));

      final result = Response.fromJson(jsonList);

      expect(result.loginItem.name, 'login');
      expect(result.applicationMetaData.name, 'applicationMetaData');
      expect(result.language.name, 'language');
      expect(result.deviceStatusResponse.name, 'deviceStatus');
    });

    test('should throw error when Response Data is not a List', () async {
      final dynamic jsonMap =
          json.decode(fixture('application_style_cached.json'));

      expect(() => Response.fromJson(jsonMap), throwsA(isA<TypeError>()));
    });

    test('should return error response when Response Object name is null',
        () async {
      final dynamic jsonMap =
          json.decode(fixture('application_style_cached.json'));

      final result = Response.fromJson([jsonMap]);

      expect(result.hasError, true);
    });
  });
}
