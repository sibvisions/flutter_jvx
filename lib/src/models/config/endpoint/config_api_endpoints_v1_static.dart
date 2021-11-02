import '../i_config_api_endpoint.dart';

class ConfigApiEndpointsV1Static implements IConfigApiEndpoint {

  String pLogin = "/api/v2/login";
  String pStartup = "/api/startup";
  String pOpenScreen = "/api/openScreen";

  @override
  String get login => pLogin;

  @override
  String get startup => pLogin;

  @override
  String get openScreen => pOpenScreen;

}