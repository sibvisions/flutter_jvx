import '../service/api/i_api_service.dart';
import '../service/service.dart';

///
///  Provides an [IApiService] instance from get.it service
///
mixin ApiServiceMixin {
  final IApiService apiService = services<IApiService>();
}

mixin ApiServiceGetterMixin {
  IApiService getApiService() {
    return services<IApiService>();
  }
}
