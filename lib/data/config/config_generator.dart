import '../../src/model/config/api/endpoint_config.dart';
import '../../src/model/config/api/url_config.dart';

class ConfigGenerator {

  static EndpointConfig generateFixedEndpoints() {
    return EndpointConfig(
      startup: "/api/v3/startup",
      login: "/api/v2/login",
      openScreen: "/api/v2/openScreen",
      deviceStatus: "/api/deviceStatus"
    );
  }

  static UrlConfig generateMobileServerUrl(String host, int port) {
    return UrlConfig(
        host: host,
        path: "/JVx.mobile/services/mobile",
        https: false,
        port: port
    );
  }
}