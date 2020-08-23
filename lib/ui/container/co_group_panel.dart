import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'i_container.dart';
import 'co_container.dart';
import '../../utils/globals.dart' as globals;

class CoGroupPanel extends CoContainer implements IContainer {
  String text = "";

  CoGroupPanel(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoGroupPanel.withCompContext(ComponentContext componentContext) {
    return CoGroupPanel(componentContext.globalKey, componentContext.context);
  }

  void updateProperties(ChangedComponent changedcomponent) {
    super.updateProperties(changedcomponent);
    text = changedcomponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
    }

    if (child != null) {
      return SingleChildScrollView(
        key: componentId,
        child: Container(
            child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    text,
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Card(
                color: Colors.white
                    .withOpacity(globals.applicationStyle.controlsOpacity),
                margin: EdgeInsets.all(5),
                elevation: 2.0,
                child: child,
                shape: globals.applicationStyle.containerShape)
          ],
        )),
      );
    } else {
      return new Container();
    }
  }
}
