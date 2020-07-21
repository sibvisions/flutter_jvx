import 'package:flutter/material.dart';
import '../../model/api/response/response_data.dart';
import 'so_component_creator.dart';
import 'so_component_screen.dart';
import 'so_screen.dart';
import '../../model/api/request/request.dart';

abstract class IScreen {
  /// The component screen is used for building the layout and widgets of the application.
  SoComponentScreen componentScreen;

  /// Constructor for returning the default Implementation of this interface.
  factory IScreen(SoComponentCreator componentCreator) =>
      SoScreen(componentCreator);

  /// Gets called when new components, metaData or data is comming from the server.
  void update(Request request, ResponseData responseData);

  /// Returns a widget.
  ///
  /// As default this widget comes from the [componentScreen] but you can return any widget you like.
  Widget getWidget();

  /// Returns `true` when the server should be called when the user opens a screen.
  ///
  /// When `false` the server will not be called.
  bool withServer();
}
