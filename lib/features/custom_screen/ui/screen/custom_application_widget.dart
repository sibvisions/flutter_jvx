import 'package:flutter/material.dart';

import '../../../../application_widget.dart';
import '../../../../core/ui/screen/i_screen_manager.dart';
import '../../../../core/utils/app/listener/app_listener.dart';
import '../../../../core/utils/config/config.dart';

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
  final Config config;

  /// The bool which decides if the application should handle session timeouts or not.
  ///
  /// The default is `true`.
  final bool handleSessionTimeout;

  final bool rememberMeChecked;

  final bool hideLoginCheckbox;

  /// Request timeout in seconds
  final int requestTimeout;

  /// The AppListener to react to certain events during app usage
  final AppListener appListener;

  /// Widget that will be shown first when app opens
  final Widget welcomeWidget;

  const CustomApplicationWidget(
      {Key key,
      this.screenManager,
      this.config,
      this.handleSessionTimeout,
      this.appListener,
      this.welcomeWidget,
      this.rememberMeChecked,
      this.hideLoginCheckbox,
      this.requestTimeout = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ApplicationWidget(
      appListener: this.appListener,
      config: this.config,
      handleSessionTimeout: this.handleSessionTimeout,
      package: true,
      screenManager: this.screenManager,
      welcomeWidget: this.welcomeWidget,
      rememberMeChecked: this.rememberMeChecked,
      hideLoginCheckbox: this.hideLoginCheckbox,
      requestTimeout: this.requestTimeout,
    );
  }
}
