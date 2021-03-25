import 'package:flutter/material.dart';

import 'default_page_route.dart';

class DefaultPage extends MaterialPage {
  DefaultPage(
      {required Widget child,
      required String name,
      required Object arguments,
      required LocalKey? key})
      : super(child: child, key: key, name: name, arguments: arguments);

  @override
  Route createRoute(BuildContext context) {
    return DefaultPageRoute(settings: this, builder: (_) => child);
  }
}
