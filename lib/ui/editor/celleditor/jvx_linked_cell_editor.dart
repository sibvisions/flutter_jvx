import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxLinkedCellEditor extends JVxCellEditor {
  
  JVxLinkedCellEditor(ComponentProperties properties, BuildContext context) : super(properties, context);
  
void valueChanged(dynamic value) {
}

  List<DropdownMenuItem> getItems() {
      List<DropdownMenuItem> items = List<DropdownMenuItem>();

      items.add(getItem("Mr.", "Mr."));
      items.add(getItem("Mrs.", "Mrs."));

      return items;
  }

  DropdownMenuItem getItem(String value, String text) {
    return DropdownMenuItem(
      value: value,
      child: Text(text)
    );
  }

  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return DropdownButton(
      items: getItems(),
      onChanged: valueChanged
    );
  }
}