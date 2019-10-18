import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxDateCellEditor extends JVxCellEditor {
  String dateFormat;
  
  JVxDateCellEditor(CellEditor changedCellEditor, BuildContext context) : super(changedCellEditor, context) {
      dateFormat = changedCellEditor.getProperty<String>(CellEditorProperty.DATE_FORMAT);
  }

  @override
  void onDateValueChanged(dynamic value) {
    super.onValueChanged(this.value);
  }
  
  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return TextField();
  }
}