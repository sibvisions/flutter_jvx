import '../../config/app_config.dart';
import '../../custom/app_manager.dart';

class InitConfig {
  final AppConfig? appConfig;
  final AppManager? appManager;
  final List<Function(Map<String, String> style)>? styleCallbacks;
  final List<Function(String language)>? languageCallbacks;
  final List<Function()>? imagesCallbacks;

  InitConfig({
    this.appConfig,
    this.appManager,
    this.styleCallbacks,
    this.languageCallbacks,
    this.imagesCallbacks,
  });
}
