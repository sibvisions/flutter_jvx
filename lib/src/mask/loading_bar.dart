import 'package:flutter/material.dart';

import '../../util/constants/i_color.dart';

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

  static Widget wrapLoadingBar(Widget child) {
    return Builder(builder: (context) {
      return Stack(children: [
        child,
        if (LoadingBar.of(context)?.show ?? false)
          LinearProgressIndicator(minHeight: 5, color: IColor.toggleColor(Theme.of(context).colorScheme.primary)),
      ]);
    });
  }
}
