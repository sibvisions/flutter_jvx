import 'package:flutter_client/src/service/config/i_config_service.dart';

class ConfigService implements IConfigService{

  String? _appName;
  String? _clientId;

  ConfigService({
    String? appName
  }) : _appName = appName;


  @override
  String? getAppName() {
    return _appName;
  }

  @override
  String? getClientId() {
    return _clientId;
  }

  @override
  void setClientId(String? clientId) {
    _clientId = clientId;
  }

  @override
  void setAppName(String appName) {
    _appName = _appName;
  }
}