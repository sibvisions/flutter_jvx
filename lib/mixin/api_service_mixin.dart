import '../src/service/api/i_api_service.dart';
import '../src/service/service.dart';

///
///  Provides an [IApiService] instance from get.it service
///

mixin ApiServiceGetterMixin {
  IApiService getApiService() {
    return services<IApiService>();
  }
}
