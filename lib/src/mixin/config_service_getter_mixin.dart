import 'package:flutter_client/src/service/config/i_config_service.dart';

import '../service/service.dart';

mixin ConfigServiceGetterMixin {
  IConfigService getConfigService() {
    return services<IConfigService>();
  }
}
