import 'package:flutter/material.dart';

import '../application_widget.dart';
import '../utils/config.dart';
import '../utils/globals.dart' as globals;
import 'custom_screen_manager/i_custom_screen_manager.dart';

/// A widget returning the entire Application.
/// 
/// Use this widget as a starting point if you use this application as a package.
class CustomApplicationWidget extends ApplicationWidget {
  /// The screen manager used to manage all the custom screens you are adding to the application.
  final ICustomScreenManager screenManager;
  /// The developer config used for setting url, appname, etc. for the application.
  /// 
  /// Just for developing.
  /// 
  /// If you use this in application in production do not enter a config.
  final Config config;
  /// The bool which decides if the application should handle session timeouts or not.
  /// 
  /// The default is `true`.
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
