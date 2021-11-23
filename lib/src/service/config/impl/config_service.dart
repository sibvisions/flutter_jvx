import 'package:flutter_client/src/service/config/i_config_service.dart';

/// Stores all config and session based data.
// Author: Michael Schober
class ConfigService implements IConfigService{

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the app.
  String? _appName;

  /// Client id of the current session.
  String? _clientId;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ///Initializes an [ConfigService]
  ConfigService({
    String? appName
  }) : _appName = appName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
  void setAppName(String? appName) {
    _appName = _appName;
  }
}