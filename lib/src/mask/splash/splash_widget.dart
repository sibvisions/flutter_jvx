import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/splash/loading_widget.dart';

import '../../../init_app_mobile.dart' if (dart.library.html) '../../../init_app_web.dart';

class SplashWidget extends StatefulWidget {
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

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late Future<bool> initAppFuture;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    initAppFuture = initApp(
      initContext: context,
      languageCallbacks: widget.languageCallbacks,
      styleCallbacks: widget.styleCallbacks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initAppFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return const LoadingWidget();
      },
    );
  }
}
