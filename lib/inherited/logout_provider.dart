import 'package:flutter/material.dart';

/// Provider for getting the instance of the widget of [LogoutProvider]
class LogoutProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  LogoutProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static LogoutProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(LogoutProvider);

  @override
  bool updateShouldNotify(LogoutProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}