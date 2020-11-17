import 'package:flutter/material.dart';

import '../../../services/local/shared_preferences_manager.dart';

class SharedPrefProvider extends InheritedWidget {
  final Widget child;
  final SharedPreferencesManager manager;

  SharedPrefProvider({this.child, this.manager}) : super(child: child);

  static SharedPrefProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SharedPrefProvider>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
