import 'package:flutter/material.dart';
import '../../model/api/response/data/jvx_dataprovider_changed.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/api/response/meta_data/jvx_meta_data.dart';
import '../../model/api/response/screen_generic.dart';
import '../../ui/component/i_component.dart';
import '../../ui/screen/component_screen.dart';
import '../../ui/screen/i_component_creator.dart';
import '../../ui/screen/i_screen.dart';

class JVxScreen implements IScreen {
  String title = "OpenScreen";
  Key componentId;
  List<JVxData> data = <JVxData>[];
  List<JVxMetaData> metaData = <JVxMetaData>[];
  Function buttonCallback;
  ComponentScreen componentScreen;

  JVxScreen(IComponentCreator componentCreator) : componentScreen = ComponentScreen(componentCreator);
  
  @override
  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData, List<JVxDataproviderChanged> dataproviderChanged, ScreenGeneric genericScreen) {
    componentScreen.updateData(request, data, metaData);
    if (genericScreen!=null)
      componentScreen.updateComponents(genericScreen.changedComponents);
  }

  @override
  Widget getWidget() {
    if (componentScreen.debug) componentScreen.debugPrintCurrentWidgetTree();

    IComponent component = this.componentScreen.getRootComponent();

    if (component != null) {
      return component.getWidget();
    } else {
      return Container(
        alignment: Alignment.center,
        child: Text('No root component defined!'),
      );
    }
  }

  @override
  bool withServer() {
    return true;
  }
}
