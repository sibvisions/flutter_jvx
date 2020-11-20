import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/core/services/local/shared_preferences_manager.dart';
import 'package:jvx_flutterclient/core/services/remote/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/core/services/remote/rest/rest_client.dart';
import 'package:jvx_flutterclient/core/ui/pages/startup_page.dart';
import 'package:jvx_flutterclient/core/ui/screen/screen_manager.dart';
import 'package:jvx_flutterclient/core/ui/widgets/page/startup_page_widget.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/app_state_provider.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/shared_pref_provider.dart';
import 'package:jvx_flutterclient/core/utils/config/config.dart';
import 'package:jvx_flutterclient/core/utils/network/network_info.dart';
import 'package:jvx_flutterclient/injection_container.dart' as di;
import '../../../services/remote/bloc/api_bloc_test.dart';
import '../../../utils/network/network_info_test.dart';

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

  group('widget creation', () {
    testWidgets('should create startup page widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
          child: StartupPage(shouldLoadConfig: true),
          manager: manager,
          appState: appState,
          themeData: ThemeData(),
          bloc: bloc));

      expect(find.byType(StartupPageWidget), findsOneWidget);
    });

    testWidgets('should find text and loading widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
          child: StartupPageWidget(
            shouldLoadConfig: false,
            config:
                Config(appName: 'APP_NAME', baseUrl: 'BASEURl', debug: true),
          ),
          appState: appState,
          manager: manager,
          bloc: bloc,
          themeData: ThemeData()));

      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

Widget makeTestableWidget(
    {Widget child,
    SharedPreferencesManager manager,
    AppState appState,
    ApiBloc bloc,
    ThemeData themeData}) {
  appState.screenManager = ScreenManager();

  appState.screenManager.init();

  appState.handleSessionTimeout = true;
  appState.package = false;

  return SharedPrefProvider(
    manager: manager,
    child: AppStateProvider(
      appState: appState,
      child: MaterialApp(
        home: Theme(
            data: themeData,
            child: BlocProvider<ApiBloc>(create: (_) => bloc, child: child)),
      ),
    ),
  );
}
