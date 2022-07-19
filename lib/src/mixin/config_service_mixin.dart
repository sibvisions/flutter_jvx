import '../service/config/i_config_service.dart';
import '../service/service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///

mixin ConfigServiceGetterMixin {
  IConfigService getConfigService() {
    return services<IConfigService>();
  }
}
