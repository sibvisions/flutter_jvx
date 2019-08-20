import 'package:flutter/widgets.dart';

/// Provider for getting the instance of the widget of [DownloadProvider]
class DownloadProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  DownloadProvider({this.validationErrorCallback, this.child});

  static DownloadProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(DownloadProvider);

  @override
  bool updateShouldNotify(DownloadProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}