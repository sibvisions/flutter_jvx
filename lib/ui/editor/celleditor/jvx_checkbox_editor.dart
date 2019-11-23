import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxCheckboxCellEditor extends JVxCellEditor {
  List<String> allowedValues;
  dynamic selectedValue = true;
  dynamic deselectedValue = false;
  String text;

  JVxCheckboxCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    selectedValue = changedCellEditor.getProperty<dynamic>(CellEditorProperty.SELECTED_VALUE, selectedValue);
    deselectedValue = changedCellEditor.getProperty<dynamic>(CellEditorProperty.DESELECTED_VALUE, deselectedValue);
    text = changedCellEditor.getProperty<String>(CellEditorProperty.TEXT, text);
  }

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  bool getBoolValue(dynamic value) {
    if (value == selectedValue) return true;
    if (value == deselectedValue) return false;
    return null;
  }

  @override
  Widget getWidget() {
    print('CHECKBOX: ' + this.value.toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          value: getBoolValue(this.value),
          onChanged: (bool change) => valueChanged(change),
          tristate: true,
        ),
        text != null ? SizedBox(width: 5,) : Container(),
        text != null ? Text(text) : Container(),
      ],
    );
  }
}
