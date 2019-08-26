import 'package:flutter/widgets.dart';

class CloseScreenProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  CloseScreenProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static CloseScreenProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(CloseScreenProvider);

  @override
  bool updateShouldNotify(CloseScreenProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}