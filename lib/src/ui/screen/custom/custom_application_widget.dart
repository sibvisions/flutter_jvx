import 'package:flutter/material.dart';

import '../../../application_widget.dart';
import '../../../util/app/listener/app_listener.dart';
import '../../../util/app/version/app_version.dart';
import '../../../util/config/app_config.dart';
import '../../../util/config/dev_config.dart';
import '../core/manager/i_screen_manager.dart';

/// A widget returning the entire Application.
///
/// Use this widget as a starting point if you use this application as a package.
class CustomApplicationWidget extends StatelessWidget {
  /// The screen manager used to manage all the custom screens you are adding to the application.
  final IScreenManager screenManager;

  /// The developer config used for setting url, appname, etc. for the application.
  ///
  /// Just for developing.
  ///
  /// If you use this in application in production do not enter a config.
  final DevConfig? config;

  /// The AppListener to react to certain events during app usage
  final AppListener? appListener;

  /// Widget that will be shown first when app opens
  final Widget? welcomeWidget;

  /// Widget that will be show while startup
  final Widget? startupWidget;

  /// Optional appconfig parameter
  ///
  /// One of [appConfig] and [appConfigPath] must be not null
  final AppConfig? appConfig;

  /// Optional appconfig path parameter
  ///
  /// One of [appConfig] and [appConfigPath] must be not null
  final String? appConfigPath;

  /// Optional app version if you want to version the app
  final AppVersion? appVersion;

  const CustomApplicationWidget(
      {Key? key,
      required this.screenManager,
      this.config,
      this.appListener,
      this.welcomeWidget,
      this.startupWidget,
      this.appConfig,
      this.appConfigPath,
      this.appVersion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ApplicationWidget(
      appListener: appListener,
      screenManager: screenManager,
      welcomeWidget: welcomeWidget,
      startupWidget: startupWidget,
      devConfig: config,
      appConfig: appConfig,
      appConfigPath: appConfigPath,
      appVersion: appVersion,
      package: true,
    );
  }
}
