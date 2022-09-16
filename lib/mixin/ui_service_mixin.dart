import '../src/service/config/i_config_service.dart';
import '../src/service/service.dart';
import '../src/service/ui/i_ui_service.dart';

export '../src/service/ui/i_ui_service.dart';
export '../src/service/ui/impl/ui_service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///
mixin UiServiceGetterMixin {
  IUiService getUiService() {
    return services<IUiService>();
  }
}
