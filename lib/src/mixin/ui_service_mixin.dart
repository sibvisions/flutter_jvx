import '../service/config/i_config_service.dart';
import '../service/service.dart';
import '../service/ui/i_ui_service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///

mixin UiServiceGetterMixin {
  IUiService getUiService() {
    return services<IUiService>();
  }
}
