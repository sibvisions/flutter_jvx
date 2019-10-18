import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/api/response/screen_generic.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/screen/component_screen.dart';
import 'package:jvx_mobile_v3/ui/screen/i_component_creator.dart';

class JVxScreen extends ComponentScreen {
  String title = "OpenScreen";
  Key componentId;
  List<JVxData> data = <JVxData>[];
  List<JVxMetaData> metaData = <JVxMetaData>[];
  Function buttonCallback;

  JVxScreen(IComponentCreator componentCreator) : super(componentCreator);
  
  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData, ScreenGeneric genericScreen) {
    updateData(request, data, metaData);
    if (genericScreen!=null)
      updateComponents(genericScreen.changedComponents);
  }

  Widget getWidget() {
    if (debug) debugPrintCurrentWidgetTree();

    IComponent component = this.getRootComponent();

    if (component != null) {
      return component.getWidget();
    } else {
      // ToDO
      return Container(
        alignment: Alignment.center,
        child: Text('No root component defined!'),
      );
    }
  }
}
