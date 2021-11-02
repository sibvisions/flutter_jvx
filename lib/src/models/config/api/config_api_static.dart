import 'package:flutter_jvx/src/models/config/i_config_api_endpoint.dart';
import 'package:flutter_jvx/src/models/config/i_config_api_url.dart';
import 'package:flutter_jvx/src/models/config/i_config_api.dart';

class ConfigApiStatic implements IConfigApi{

  IConfigApiUrl urlConfig;
  IConfigApiEndpoint endpointConfig;

  ConfigApiStatic({
    required this.urlConfig,
    required this.endpointConfig
  });



  @override
  Uri getLogin() {
    return Uri.parse(urlConfig.basePath + endpointConfig.login);
  }

  @override
  Uri getStartup() {
    return Uri.parse(urlConfig.basePath + endpointConfig.startup);
  }

  @override
  Uri getOpenScreen() {
    return Uri.parse(urlConfig.basePath + endpointConfig.openScreen);
  }
}