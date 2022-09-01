import 'package:flutter/widgets.dart';

import '../../config/app_config.dart';
import '../../custom/app_manager.dart';

class InitConfig {
  final AppConfig? appConfig;
  final AppManager? appManager;
  final Widget Function(BuildContext context)? loadingBuilder;
  final List<Function(Map<String, String> style)>? styleCallbacks;
  final List<Function(String language)>? languageCallbacks;
  final List<Function()>? imagesCallbacks;

  InitConfig({
    this.appConfig,
    this.appManager,
    this.loadingBuilder,
    this.styleCallbacks,
    this.languageCallbacks,
    this.imagesCallbacks,
  });
}
