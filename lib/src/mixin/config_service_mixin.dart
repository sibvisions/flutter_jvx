import 'package:flutter_client/src/service/config/i_config_service.dart';
import 'package:flutter_client/src/service/service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///
mixin ConfigServiceMixin {
  final IConfigService configService = services<IConfigService>();
}