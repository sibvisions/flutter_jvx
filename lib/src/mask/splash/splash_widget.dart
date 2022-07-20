import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../init_app.dart';
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

  late Future<void> initAppFuture;

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
    ).catchError((error, stackTrace) {
      LOGGER.logE(pType: LOG_TYPE.GENERAL, pMessage: error.toString(), pStacktrace: stackTrace);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              await SystemNavigator.pop();
              return false;
            },
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor.withAlpha(255),
              title: const Text("FATAL ERROR"),
              content: Text(error.toString()),
              actions: _getButtons(context),
            ),
          );
        },
      );
    });
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all possible actions
  List<Widget> _getButtons(BuildContext context) {
    List<Widget> actions = [];

    if (!kIsWeb) {
      actions.add(
        TextButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          child: const Text(
            "Exit App",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return actions;
  }
}
