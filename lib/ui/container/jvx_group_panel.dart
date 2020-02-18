import 'package:flutter/material.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/container/i_container.dart';
import '../../ui/container/jvx_container.dart';

class JVxGroupPanel extends JVxContainer implements IContainer {
  Key key = GlobalKey();
  String text = "";

  JVxGroupPanel(Key componentId, BuildContext context)
      : super(componentId, context);

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
      return  SingleChildScrollView(
          key: key,
          child: Container(
        child:
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8),
              child:
                Row(
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
            child
          ],
        ),
        ),
      );
    } else {
      return new Container();
    }
  }
}
