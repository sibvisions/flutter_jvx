import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxTextCellEditor extends JVxCellEditor {
  bool multiLine = false;
  
  JVxTextCellEditor(ComponentProperties properties, BuildContext context) : super(properties, context) {
    multiLine = properties.getProperty<String>('contentType').contains('multiline');
  }
  
  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return TextField(
      maxLines: multiLine ? null : 1,
      keyboardType: multiLine ? TextInputType.multiline : TextInputType.text,
    );
  }
}