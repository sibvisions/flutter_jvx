import 'package:flutter/material.dart';

import '../../model/response/application_settings_response.dart';

class AppStyle extends InheritedWidget {
  final Map<String, String>? applicationStyle;

  final ApplicationSettingsResponse applicationSettings;

  const AppStyle({
    super.key,
    required this.applicationStyle,
    required this.applicationSettings,
    required super.child,
  });

  static AppStyle? of(BuildContext? context) => context?.dependOnInheritedWidgetOfExactType<AppStyle>();

  @override
  bool updateShouldNotify(covariant AppStyle oldWidget) =>
      applicationStyle != oldWidget.applicationStyle && applicationSettings != oldWidget.applicationSettings;
}
