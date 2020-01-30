import 'package:flutter/material.dart';

import '../application_widget.dart';
import '../utils/config.dart';
import '../utils/globals.dart' as globals;
import 'custom_screen_manager/i_custom_screen_manager.dart';

class CustomApplicationWidget extends ApplicationWidget {
  final ICustomScreenManager screenManager;
  final Config config;
  final bool handleSessionTimeout;

  CustomApplicationWidget({this.screenManager, this.config, this.handleSessionTimeout}) : super(config: config);

  @override
  Widget build(BuildContext context) {
    if (screenManager != null) {
      globals.customScreenManager = this.screenManager;
    }
    if (handleSessionTimeout != null) {
      globals.handleSessionTimeout = this.handleSessionTimeout;
    }
    globals.package = true;
    
    return super.build(context);
  }
}
