import '../service/config/i_config_service.dart';
import '../service/service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///
mixin ConfigServiceMixin {
  final IConfigService configService = services<IConfigService>();
}

mixin ConfigServiceGetterMixin {
  IConfigService getConfigService() {
    return services<IConfigService>();
  }
}
