import 'package:flutter/widgets.dart';

class OpenScreenProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  OpenScreenProvider({this.validationErrorCallback, this.child}) : super(child: child);

  static OpenScreenProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(OpenScreenProvider);

  @override
  bool updateShouldNotify(OpenScreenProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}