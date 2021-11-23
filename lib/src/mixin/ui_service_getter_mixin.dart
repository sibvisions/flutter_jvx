import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

mixin UiServiceGetterMixin {
  IUiService getUiService() {
    return services<IUiService>();
  }
}