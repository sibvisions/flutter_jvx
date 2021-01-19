import 'package:connectivity/connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/i_offline_database_provider.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/offline_database.dart';
import 'package:jvx_flutterclient/core/utils/translation/supported_locale_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/models/api/response.dart';
import 'core/models/app/app_state.dart';
import 'core/services/local/shared_preferences_manager.dart';
import 'core/services/remote/bloc/api_bloc.dart';
import 'core/services/remote/rest/http_client.dart';
import 'core/services/remote/rest/rest_client.dart';
import 'core/utils/network/network_info.dart';
import 'core/utils/theme/theme_manager.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => ApiBloc(
      Response(),
      sl<NetworkInfo>(),
      sl<RestClient>(),
      sl<AppState>(),
      sl<SharedPreferencesManager>(),
      sl<IOfflineDatabaseProvider>()));

  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()));
  sl.registerLazySingleton<RestClient>(() => RestClient(sl<HttpClient>()));
  sl.registerLazySingleton<ThemeManager>(() => ThemeManager());
  sl.registerLazySingleton<SupportedLocaleManager>(
      () => SupportedLocaleManager());
  sl.registerLazySingleton<SharedPreferencesManager>(
      () => SharedPreferencesManager(sl<SharedPreferences>()));
  sl.registerLazySingleton<AppState>(() => AppState());

  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<HttpClient>(() => HttpClient());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<IOfflineDatabaseProvider>(() => OfflineDatabase());
}
