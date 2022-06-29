import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/splash/loading_widget.dart';

import '../../../init_app_mobile.dart' if (dart.library.html) '../../../init_app_web.dart';

class SplashWidget extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<Function>? styleCallbacks;

  final List<Function>? languageCallbacks;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SplashWidget({
    Key? key,
    this.styleCallbacks,
    this.languageCallbacks,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: initApp(initContext: context, languageCallbacks: languageCallbacks, styleCallbacks: styleCallbacks),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return const LoadingWidget();
        },
      ),
    );
  }
}
