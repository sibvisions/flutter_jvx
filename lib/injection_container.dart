import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
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
  sl.registerFactory(() => ApiBloc(Response(), sl(), sl(), sl(), sl()));

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => RestClient(sl()));
  sl.registerLazySingleton(() => ThemeManager());
  sl.registerLazySingleton(() => SharedPreferencesManager(sl()));
  sl.registerLazySingleton(() => AppState());

  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => HttpClient());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
