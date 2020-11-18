import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_flutterclient/core/models/api/request.dart';
import 'package:jvx_flutterclient/core/models/api/request/application_style.dart';
import 'package:jvx_flutterclient/core/models/api/request/loading.dart';
import 'package:jvx_flutterclient/core/models/api/request/login.dart';
import 'package:jvx_flutterclient/core/models/api/request/startup.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/models/api/response/application_meta_data.dart';
import 'package:jvx_flutterclient/core/models/api/response/language.dart';
import 'package:jvx_flutterclient/core/models/api/response/login_item.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/core/models/app/i_app_state.dart';
import 'package:jvx_flutterclient/core/services/local/shared_preferences_manager.dart';
import 'package:jvx_flutterclient/core/services/remote/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/core/services/remote/rest/http_client.dart';
import 'package:jvx_flutterclient/core/services/remote/rest/rest_client.dart';
import 'package:jvx_flutterclient/core/utils/network/network_info.dart';
import 'package:jvx_flutterclient/injection_container.dart' as di;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../../../utils/network/network_info_test.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await di.init();

  ApiBloc bloc;
  NetworkInfoImpl networkInfo;
  RestClient restClient;
  SharedPreferencesManager manager;
  AppState appState;
  Response response;

  MockHttpClient mockHttpClient;
  MockConnectivity mockConnectivity;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockHttpClient = MockHttpClient();
    mockSharedPreferences = MockSharedPreferences();

    restClient = RestClient(mockHttpClient);
    networkInfo = NetworkInfoImpl(mockConnectivity);
    manager = SharedPreferencesManager(mockSharedPreferences);
    appState = AppState();
    response = Response();

    bloc = ApiBloc(response, networkInfo, restClient, appState, manager);
  });

  test('initial state should not have an error', () async {
    expect(response.hasError, false);
  });

  group('Startup', () {
    final tAppName = 'demo';
    final tBaseUrl = 'http://192.168.0.60:8080/JVx.mobile/services/mobile';
    final tAppMode = 'full';
    final tDeviceId = Uuid().v1();

    final tStartup = Startup(
        appMode: tAppMode,
        applicationName: tAppName,
        url: tBaseUrl,
        authKey: null,
        layoutMode: 'generic',
        deviceId: tDeviceId,
        readAheadLimit: 100,
        requestType: RequestType.STARTUP);

    final tStartupResponse =
        Response.fromJson(json.decode(fixture('startup_cached.json')));

    test('should call restclient when startup request', () async {
      when(restClient.post(any, tStartup.toJson()))
          .thenAnswer((_) => Future.value(tStartupResponse));

      bloc.add(tStartup);

      await untilCalled(restClient.post(any, tStartup.toJson()));

      verify(bloc.processRequest(tStartup));
    });

    test('should emit response when request was succesful', () async {
      when(restClient.post(any, tStartup.toJson()))
          .thenAnswer((_) => Future.value(tStartupResponse));

      final expected = [Response()..request = Loading(), tStartupResponse];

      expectLater(bloc, emitsInOrder(expected));

      bloc.add(tStartup);
    });
  });

  final tLogin = Login(
      clientId: 'CLIENT_ID',
      createAuthKey: true,
      password: 'features',
      requestType: RequestType.LOGIN,
      username: 'features');

  final tLoginResponse =
      Response.fromJson(json.decode(fixture('login_cached.json')));

  group('Login', () {
    test('should call restclient when login request', () async {
      when(restClient.post(any, tLogin.toJson()))
          .thenAnswer((_) => Future.value(tLoginResponse));

      bloc.add(tLogin);

      await untilCalled(restClient.post(any, tLogin.toJson()));

      verify(bloc.processRequest(tLogin));
    });

    test('should emit response when request was succesfull', () async {
      when(restClient.post(any, tLogin.toJson()))
          .thenAnswer((_) => Future.value(tLoginResponse));

      final expected = [Response()..request = Loading(), tLoginResponse];

      expectLater(bloc, emitsInOrder(expected));

      bloc.add(tLogin);
    });
  });

  group('ApplicationSyle', () {
    final tApplicationStyle = ApplicationStyle(
        clientId: 'CLIENT_ID',
        contentMode: 'json',
        name: 'applicationStyle',
        requestType: RequestType.APP_STYLE);

    Map<String, dynamic> cachedResponse =
        json.decode(fixture('application_style_cached.json'));

    cachedResponse['name'] = 'application.style';

    final tApplicationStyleResponse = Response.fromJson([cachedResponse]);

    test('should call restclient when app style request', () async {
      when(restClient.post(any, tApplicationStyle.toJson()))
          .thenAnswer((_) => Future.value(tApplicationStyleResponse));

      bloc.add(tApplicationStyle);

      await untilCalled(restClient.post(any, tApplicationStyle.toJson()));

      verify(bloc.processRequest(tApplicationStyle));
    });

    test('should emit response when request was succesfull', () async {
      when(restClient.post(any, tApplicationStyle.toJson()))
          .thenAnswer((_) => Future.value(tApplicationStyleResponse));

      final expected = [Response()..request = Loading(), tApplicationStyle];

      expectLater(bloc, emitsInOrder(expected));

      bloc.add(tApplicationStyle);
    });
  });
}
