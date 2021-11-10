import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/util/app/state/state_helper.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../services/repository/api_repository_impl_test.mocks.dart';

void main() {
  late AppState appState;
  late SharedPreferencesManager manager;

  setUpAll(() {
    init();

    appState = AppState();
    manager =
        SharedPreferencesManager(sharedPreferences: MockSharedPreferences());
  });

  group('should set appstate', () {
    test('with startup response', () async {
      final tStartupRequest = StartupRequest(
          appMode: 'full',
          appName: 'test',
          deviceId: '',
          language: '',
          readAheadLimit: 100,
          screenHeight: 213,
          screenWidth: 123,
          url: '',
          clientId: '');

      final tStartupResponse = ApiResponse.fromJson(
          tStartupRequest, json.decode(fixture('startup_response.json')));

      StateHelper.updateAppStateWithStartupResponse(appState, tStartupResponse);

      expect(appState.applicationMetaData, isNotNull);
      expect(appState.language, isNotNull);
      expect(appState.userData, isNotNull);
      expect(appState.deviceStatus, isNotNull);
      expect(appState.menuResponseObject.entries, isNotEmpty);
    });

    test('with local data', () async {});
  });
}
