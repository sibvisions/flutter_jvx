import 'package:flutter/widgets.dart';

class LoadingBar extends InheritedWidget {
  final bool show;

  const LoadingBar({
    super.key,
    required this.show,
    required super.child,
  });

  static LoadingBar? of(BuildContext? context) => context?.dependOnInheritedWidgetOfExactType<LoadingBar>();

  @override
  bool updateShouldNotify(covariant LoadingBar oldWidget) => show != oldWidget.show;
}
