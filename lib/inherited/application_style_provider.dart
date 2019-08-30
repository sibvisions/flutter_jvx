import 'package:flutter/widgets.dart';

class ApplicationStyleProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  ApplicationStyleProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static ApplicationStyleProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(ApplicationStyleProvider);

  @override
  bool updateShouldNotify(ApplicationStyleProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}