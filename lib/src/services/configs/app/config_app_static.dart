

import 'package:flutter_jvx/src/services/configs/i_config_app.dart';

class ConfigAppService implements IConfigApp {


  String pAppName;
  String pTheme;
  String? pClientId;
  bool pIsAuthenticated;

  ConfigAppService({
    required this.pAppName,
    required this.pTheme,
    this.pClientId,
    this.pIsAuthenticated = false
  });



  // ---- Getters

  @override
  String get appName => pAppName;

  @override
  String get theme => pTheme;

  @override
  String? get clientId => pClientId;

  @override
  bool get authenticated => pIsAuthenticated;


  // ---- Setters

  @override
  set clientId(String? clientId) {
    pClientId = clientId;
  }

  @override
  set authenticated(bool isAuthenticated) {
    pIsAuthenticated = isAuthenticated;
  }

}