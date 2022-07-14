import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../init_app_mobile.dart' if (dart.library.html) '../../../init_app_web.dart';
import '../../../util/logging/flutter_logger.dart';
import 'loading_widget.dart';

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
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "initState");

    initAppFuture = initApp(
      initContext: context,
      languageCallbacks: widget.languageCallbacks,
      styleCallbacks: widget.styleCallbacks,
    );
  }

  @override
  Widget build(BuildContext context) {
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "build");

    return FutureBuilder(
      future: initAppFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return const LoadingWidget();
      },
    );
  }
}
