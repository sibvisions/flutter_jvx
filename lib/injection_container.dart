import 'package:flutterclient/src/models/api/remote_data_source.dart';
import 'package:flutterclient/src/models/api/remote_data_source_impl.dart';
import 'package:flutterclient/src/models/repository/api_repository.dart';
import 'package:flutterclient/src/models/repository/api_repository_impl.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/locale/supported_locale_manager.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';
import 'package:flutterclient/src/services/remote/network_info/network_info.dart';
import 'package:flutterclient/src/services/remote/rest/http_client.dart';
import 'package:flutterclient/src/services/remote/rest/rest_client.dart';
import 'package:flutterclient/src/util/theme/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<ApiCubit>(() =>
      ApiCubit(client: sl(), appState: sl(), manager: sl(), networkInfo: sl()));

  sl.registerLazySingleton<ApiRepository>(
      () => ApiRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(client: sl()));

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
}
