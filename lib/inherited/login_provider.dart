import 'package:flutter/material.dart';

/// Provider for getting the instance of the widget of [LoginProvider]
class LoginProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  LoginProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static LoginProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(LoginProvider);

  @override
  bool updateShouldNotify(LoginProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}