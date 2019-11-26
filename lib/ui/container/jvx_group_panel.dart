import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/container/i_container.dart';
import 'package:jvx_mobile_v3/ui/container/jvx_container.dart';


class JVxGroupPanel extends JVxContainer implements IContainer {
  String text = "";

  JVxGroupPanel(Key componentId, BuildContext context) : super(componentId, context);

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

    if (child!= null) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 10,),
                Text(text, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
              ],
            ) ,
            Divider(color: Colors.grey[600], height: 10,),
            child
          ],
        ),
      );
    } else {
      return new Container();
    }
  }
}