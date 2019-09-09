import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxLinkedCellEditor extends JVxCellEditor {
  
  JVxLinkedCellEditor(ComponentProperties properties, BuildContext context) : super(properties, context);
  
  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return DropdownButton();
  }
}