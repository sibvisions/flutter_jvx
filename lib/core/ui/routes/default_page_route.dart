import 'package:flutter/material.dart';

class DefaultPageRoute<T> extends MaterialPageRoute<T> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  DefaultPageRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var begin = Offset(1.0, 0.0);
    var end = Offset.zero;
    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}
