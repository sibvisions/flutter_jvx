import 'package:flutter/material.dart';

/// Provider for getting the instance of the widget of [StartupProvider]
class StartupProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  StartupProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static StartupProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(StartupProvider);

  @override
  bool updateShouldNotify(StartupProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}