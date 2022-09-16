import '../src/service/api/i_api_service.dart';
import '../src/service/service.dart';

export '../src/service/api/i_api_service.dart';
export '../src/service/api/impl/default/api_service.dart';

///
///  Provides an [IApiService] instance from get.it service
///
mixin ApiServiceGetterMixin {
  IApiService getApiService() {
    return services<IApiService>();
  }
}
