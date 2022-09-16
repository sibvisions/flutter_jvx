import '../src/service/config/i_config_service.dart';
import '../src/service/service.dart';

export '../src/service/config/i_config_service.dart';
export '../src/service/config/impl/config_service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///
mixin ConfigServiceGetterMixin {
  IConfigService getConfigService() {
    return services<IConfigService>();
  }
}
