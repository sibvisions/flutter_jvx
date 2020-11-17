import 'package:flutter/material.dart';

import '../../../models/app/app_state.dart';

class AppStateProvider extends InheritedWidget {
  final Widget child;
  final AppState appState;

  AppStateProvider({this.child, this.appState}) : super(child: child);

  static AppStateProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateProvider>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
