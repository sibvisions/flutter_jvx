import '../service/service.dart';
import '../service/ui/i_ui_service.dart';

mixin UiServiceGetterMixin {
  IUiService getUiService() {
    return services<IUiService>();
  }
}