import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';

import '../../mask/splash/splash_widget.dart';

class SplashLocation extends BeamLocation<BeamState> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<Function>? styleCallbacks;

  final List<Function>? languageCallbacks;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SplashLocation({
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
          languageCallbacks: languageCallbacks,
          styleCallbacks: styleCallbacks,
        ),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ["/splash"];
}
