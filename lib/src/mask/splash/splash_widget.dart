import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/splash/loading_widget.dart';

import '../../../init_app_mobile.dart' if (dart.library.html) '../../../init_app_web.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: initApp(initContext: context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return const LoadingWidget();
        },
      ),
    );
  }
}
