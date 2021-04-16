import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DefaultPageRoute<T> extends MaterialPageRoute<T> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  DefaultPageRoute(
      {required WidgetBuilder builder,
      RouteSettings? settings,
      bool maintainState = true})
      : super(
            builder: builder, settings: settings, maintainState: maintainState);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (kIsWeb) {
      return super
          .buildTransitions(context, animation, secondaryAnimation, child);
    } else {
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
}
