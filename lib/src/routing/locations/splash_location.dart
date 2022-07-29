import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_client/src/model/config/config_file/app_config.dart';

import '../../mask/splash/splash_widget.dart';

class SplashLocation extends BeamLocation<BeamState> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final AppConfig? appConfig;

  final List<Function(Map<String, String> style)>? styleCallbacks;

  final List<Function(String language)>? languageCallbacks;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SplashLocation({
    this.appConfig,
    this.languageCallbacks,
    this.styleCallbacks,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: SplashWidget(
          appConfig: appConfig,
          languageCallbacks: languageCallbacks,
          styleCallbacks: styleCallbacks,
        ),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ["/splash"];
}
