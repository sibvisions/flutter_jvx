import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/response_data.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/screen_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/so_component_creator.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen.dart/so_screen.dart';

import 'component_screen_widget.dart';

abstract class IScreen {
  /// The component screen is used for building the layout and widgets of the application.
  // ComponentScreenWidget componentScreen;

  /// Constructor for returning the default Implementation of this interface.
  factory IScreen(SoComponentCreator componentCreator) =>
      SoScreen(componentCreator);

  /// Gets called when new components, metaData or data is comming from the server.
  void update(Request request, ResponseData responseData);

  /// Returns a widget.
  ///
  /// As default this widget comes from the [componentScreen] but you can return any widget you like.
  Widget getWidget(Request request, ResponseData responseData);

  /// Returns `true` when the server should be called when the user opens a screen.
  ///
  /// When `false` the server will not be called.
  bool withServer();
}
