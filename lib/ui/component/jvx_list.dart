import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';

class JVxList extends JVxComponent {
  List data;
  JVxList(Key componentId, BuildContext context) : super(componentId, context);
  
  @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    data = properties.getProperty<List>("data");
  }

  @override
  Widget getWidget() {
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: data.length,
      itemBuilder: (_, int index) {
        return ListTile(
          title: Text(data[index].title)
        );
      },
    );
  }
}