import 'endpoint_config.dart';
import 'url_config.dart';

class ApiConfig {
  final UrlConfig urlConfig;
  final EndpointConfig endpointConfig;

  ApiConfig({
    required this.urlConfig,
    required this.endpointConfig
  });

  Uri getStartupUri() {
    return Uri.parse(urlConfig.getBasePath() + endpointConfig.startup);
  }

  Uri getLoginUri() {
    return Uri.parse(urlConfig.getBasePath() + endpointConfig.login);
  }

  Uri getOpenScreenUri() {
    return Uri.parse(urlConfig.getBasePath() + endpointConfig.openScreen);
  }

  Uri getDeviceStatusUri() {
    return Uri.parse(urlConfig.getBasePath() + endpointConfig.deviceStatus);
  }
}