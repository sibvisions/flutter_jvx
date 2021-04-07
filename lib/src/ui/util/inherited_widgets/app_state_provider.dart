import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/state/app_state.dart';

class AppStateProvider extends InheritedWidget {
  final Widget child;
  final AppState appState;

  AppStateProvider({required this.child, required this.appState})
      : super(child: child);

  static AppStateProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
