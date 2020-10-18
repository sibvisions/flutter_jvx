import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_creator.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_screen.dart';

abstract class IScreen {
  /// The component screen is used for building the layout and widgets of the application.
  // ComponentScreenWidget componentScreen;

  /// Constructor for returning the default Implementation of this interface.
  factory IScreen(SoComponentCreator componentCreator, GlobalKey globalKey) =>
      SoScreen();

  /// Returns a widget.
  ///
  /// As default this widget comes from the [componentScreen] but you can return any widget you like.
  // Widget getWidget(Request request, ResponseData responseData);

  /// Returns `true` when the server should be called when the user opens a screen.
  ///
  /// When `false` the server will not be called.
  bool withServer();
}
