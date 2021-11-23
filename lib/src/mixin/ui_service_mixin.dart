import 'package:flutter_client/src/service/config/i_config_service.dart';
import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///
mixin UiServiceMixin {
  final IUiService uiService = services<IUiService>();
}