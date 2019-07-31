import 'package:flutter/widgets.dart';

/// Provider for getting the instance of the widget of [ImageDownloadProvider]
class ImageDownloadProvider extends InheritedWidget {
  final Function validationErrorCallback;
  final Widget child;

  ImageDownloadProvider({this.validationErrorCallback, this.child});

  static ImageDownloadProvider of(BuildContext context) => context.inheritFromWidgetOfExactType(ImageDownloadProvider);

  @override
  bool updateShouldNotify(ImageDownloadProvider oldWidget) => validationErrorCallback != oldWidget.validationErrorCallback;
}