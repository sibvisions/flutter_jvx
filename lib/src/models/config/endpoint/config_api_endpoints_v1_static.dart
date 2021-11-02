import '../i_config_api_endpoint.dart';

class ConfigApiEndpointsV1Static implements IConfigApiEndpoint {

  String loginI = "/api/v2/login";
  String startupI = "/api/startup";

  @override
  String get login => loginI;

  @override
  String get startup => startupI;

}