import 'package:flutter/material.dart';
import '../../model/api/response/data/jvx_dataprovider_changed.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/component_screen.dart';
import '../../ui/screen/screen.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/api/response/meta_data/jvx_meta_data.dart';
import '../../model/api/response/screen_generic.dart';

abstract class IScreen {
  /// The component screen is used for building the layout and widgets of the application.
  ComponentScreen componentScreen;

  /// Constructor for returning the default Implementation of this interface. 
  factory IScreen(ComponentCreator componentCreator) => JVxScreen(componentCreator);

  /// Gets called when new components, metaData or data is comming from the server.
  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData, 
    List<JVxDataproviderChanged> dataproviderChanged, ScreenGeneric genericScreen);

  /// Returns a widget.
  /// 
  /// As default this widget comes from the [componentScreen] but you can return any widget you like.
  Widget getWidget();

  /// Returns `true` when the server should be called when the user opens a screen.
  /// 
  /// When `false` the server will not be called.
  bool withServer();
}
