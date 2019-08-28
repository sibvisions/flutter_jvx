import 'package:flutter/widgets.dart';

class PressButtonProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  PressButtonProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static PressButtonProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(PressButtonProvider);

  @override
  bool updateShouldNotify(PressButtonProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}