import 'package:flutter/material.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';

class SharedPreferencesProvider extends InheritedWidget {
  final Widget child;
  final SharedPreferencesManager manager;

  SharedPreferencesProvider({required this.child, required this.manager})
      : super(child: child);

  static SharedPreferencesProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SharedPreferencesProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
