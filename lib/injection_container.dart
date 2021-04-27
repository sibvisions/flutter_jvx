import 'package:archive/archive.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/models/api/data_source.dart';
import 'src/models/api/remote_data_source_impl.dart';
import 'src/models/repository/api_repository.dart';
import 'src/models/repository/api_repository_impl.dart';
import 'src/models/state/app_state.dart';
import 'src/services/local/local_database/i_offline_database_provider.dart';
import 'src/services/local/local_database/offline_database.dart';
import 'src/services/local/locale/supported_locale_manager.dart';
import 'src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'src/services/remote/cubit/api_cubit.dart';
import 'src/services/remote/network_info/network_info.dart';
import 'src/services/remote/rest/http_client.dart';
import 'src/services/remote/rest/rest_client.dart';
import 'src/util/theme/theme_manager.dart';

/// Dependency locator instance.
/// 
/// Usage:
/// ````dart
/// TypeOfInstance instance = sl<TypeOfInstance>();
/// ````
final sl = GetIt.instance;

/// Initializes all dependencies for the application.
/// 
/// If needed register instances like this:
/// ````dart
/// sl.registerLazySingleton<TypeOfInstance>(() => yourInstance);
/// ````
Future<void> init({IOfflineDatabaseProvider? offlineDatabase}) async {
  sl.registerLazySingleton<ApiCubit>(() => ApiCubit(
      repository: sl(), appState: sl(), manager: sl(), networkInfo: sl()));

  sl.registerLazySingleton<ApiRepository>(() => ApiRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
      appState: sl(),
      manager: sl(),
      offlineDataSource: sl(),
      decoder: sl()));

  sl.registerLazySingleton<DataSource>(
      () => RemoteDataSourceImpl(client: sl(), appState: sl()));

  sl.registerLazySingleton<RestClient>(() => RestClientImpl(client: sl()));

  sl.registerLazySingleton<ThemeManager>(() => ThemeManager());
  sl.registerLazySingleton<SharedPreferencesManager>(
      () => SharedPreferencesManager(sharedPreferences: sl()));
  sl.registerLazySingleton<SupportedLocaleManager>(
      () => SupportedLocaleManager());

  sl.registerLazySingleton<AppState>(() => AppState());

  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<HttpClient>(() => HttpClient());

  sl.registerLazySingleton<ZipDecoder>(() => ZipDecoder());

  if (offlineDatabase != null) {
    sl.registerLazySingleton<IOfflineDatabaseProvider>(() => offlineDatabase);
  } else {
    sl.registerLazySingleton<IOfflineDatabaseProvider>(() => OfflineDatabase());
  }
}
