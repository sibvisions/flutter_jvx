import 'package:flutter/material.dart';

class AuthNavigator extends StatefulWidget {
  final Function(RouteSettings) isRouteAllowed;
  final String initialRoute;
  final RouteFactory onGenerateRoute;
  final RouteFactory onUnknownRoute;

  const AuthNavigator({
    Key? key,
    required this.isRouteAllowed,
    required this.initialRoute,
    required this.onGenerateRoute,
    required this.onUnknownRoute,
  }) : super(key: key);

  static _AuthNavigatorState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AuthNavigatorState>();

  @override
  _AuthNavigatorState createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: widget.initialRoute,
      onGenerateRoute: (RouteSettings settings) {
        if (widget.isRouteAllowed(settings))
          return widget.onGenerateRoute(settings);
      },
      onUnknownRoute: widget.onUnknownRoute,
    );
  }
}
