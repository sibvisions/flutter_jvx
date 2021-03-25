import 'package:flutter/material.dart';

class SharedPreferencesProvider extends InheritedWidget {
  final Widget child;
  final manager;

  SharedPreferencesProvider({required this.child, this.manager})
      : super(child: child);

  static SharedPreferencesProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SharedPreferencesProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
