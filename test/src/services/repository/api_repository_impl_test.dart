import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/data_source.dart';
import 'package:flutterclient/src/models/api/requests/download_translation_request.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/local_database/offline_database.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';
import 'package:flutterclient/src/services/remote/network_info/network_info.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterclient/injection_container.dart' as di;
import 'package:universal_html/html.dart';

import '../../../fixtures/fixture_reader.dart';
import 'api_repository_impl_test.mocks.dart';

@GenerateMocks([DataSource, ZipDecoder, NetworkInfo],
    customMocks: [MockSpec<SharedPreferences>(returnNullOnMissingStub: true)])
void main() {
  late ApiRepositoryImpl repository;
  late MockDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockSharedPreferences mockSharedPreferences;
  late MockZipDecoder mockZipDecoder;

  setUpAll(() async {
    await di.init();

    mockDataSource = MockDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockSharedPreferences = MockSharedPreferences();
    mockZipDecoder = MockZipDecoder();

    repository = ApiRepositoryImpl(
        appState: _getAppState(),
        dataSource: mockDataSource,
        manager:
            SharedPreferencesManager(sharedPreferences: mockSharedPreferences),
        networkInfo: mockNetworkInfo,
        offlineDataSource: OfflineDatabase(),
        decoder: mockZipDecoder);

    when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  });

  group('download', () {
    group('translation', () {
      final tRequest = DownloadTranslationRequest(
          clientId: 'test_client_id',
          applicationImages: false,
          contentMode: 'json',
          libraryImages: false,
          name: 'translation');

      final tBodyBytes = Uint8List.fromList('test'.codeUnits);

      test('should call decodeBytes and data source when getting valid data',
          () async {
        when(mockDataSource.downloadTranslation(tRequest))
            .thenAnswer((_) async => ApiResponse(request: tRequest, objects: [
                  DownloadResponseObject(
                      name: 'download',
                      translation: true,
                      bodyBytes: tBodyBytes)
                ]));

        when(mockZipDecoder.decodeBytes(tBodyBytes))
            .thenAnswer((_) => Archive());

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        await repository.downloadTranslation(tRequest);

        verify(mockDataSource.downloadTranslation(tRequest));
        verify(mockZipDecoder.decodeBytes(tBodyBytes));
        verify(mockNetworkInfo.isConnected);
      });
    });

    group('images', () {
      final tRequest = DownloadImagesRequest(
          clientId: 'test_client_id',
          applicationImages: true,
          libraryImages: true,
          name: 'images');

      final tBodyBytes = Uint8List.fromList('test'.codeUnits);

      test('should call decodeBytes and data source when getting valid data',
          () async {
        when(mockDataSource.downloadImages(tRequest))
            .thenAnswer((_) async => ApiResponse(request: tRequest, objects: [
                  DownloadResponseObject(
                      name: 'images', translation: false, bodyBytes: tBodyBytes)
                ]));

        when(mockZipDecoder.decodeBytes(tBodyBytes))
            .thenAnswer((_) => Archive());

        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        await repository.downloadImages(tRequest);

        verify(mockDataSource.downloadImages(tRequest));
        verify(mockZipDecoder.decodeBytes(tBodyBytes));
        verify(mockNetworkInfo.isConnected);
      });
    });
  });

  group('startup', () {
    final tStartup = StartupRequest(
        appMode: 'full',
        appName: 'test',
        clientId: 'test_clientId',
        deviceId: 'test_deviceId',
        language: 'en',
        layoutMode: 'generic',
        readAheadLimit: 100,
        screenHeight: 200,
        screenWidth: 200,
        url: 'test.com');

    final tResponse = ApiResponse.fromJson(
        tStartup, json.decode(fixture('startup_response.json')));

    final tError = ApiError(
        failure: ServerFailure(
            name: 'message.error',
            details: '',
            message: 'Could not parse response',
            title: 'Parsing error'));

    test('should return ApiResponse with valid data', () async {
      when(mockDataSource.startup(tStartup)).thenAnswer((_) async => tResponse);

      final result = await repository.startup(tStartup);

      expect(result, tResponse);
    });

    test('should return ApiError with invalid data', () async {
      when(mockDataSource.startup(tStartup)).thenAnswer((_) async => tError);

      final result = await repository.startup(tStartup);

      expect(result, tError);
    });
  });
}

_getAppState() {
  return AppState()
    ..serverConfig =
        ServerConfig(baseUrl: 'testw/wdwdw/wdwqd/wdwdw', appName: 'test')
    ..applicationMetaData = ApplicationMetaDataResponseObject(
        name: 'applicationMetaData',
        langCode: 'en',
        languageResource: 'test',
        clientId: 'test_clientId',
        version: '1.0.0');
}
