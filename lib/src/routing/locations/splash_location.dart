import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../config/app_config.dart';
import '../../../custom/app_manager.dart';
import '../../mask/splash/splash_widget.dart';

class SplashLocation extends BeamLocation<BeamState> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final AppConfig? appConfig;

  final AppManager? appManager;

  final Widget Function(BuildContext context)? loadingBuilder;

  final List<Function(Map<String, String> style)>? styleCallbacks;

  final List<Function(String language)>? languageCallbacks;

  final List<Function()>? imagesCallbacks;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SplashLocation({
    this.appConfig,
    this.appManager,
    this.loadingBuilder,
    this.styleCallbacks,
    this.languageCallbacks,
    this.imagesCallbacks,
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
          appManager: appManager,
          loadingBuilder: loadingBuilder,
          styleCallbacks: styleCallbacks,
          languageCallbacks: languageCallbacks,
          imagesCallbacks: imagesCallbacks,
        ),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ["/splash"];
}
