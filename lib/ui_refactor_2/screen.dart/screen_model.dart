import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/component_screen_widget.dart';

class ScreenModel extends ValueNotifier {
  String title;
  ComponentScreenWidgetState state;

  ScreenModel(this.title) : super(null);
}
