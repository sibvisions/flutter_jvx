import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxCheckboxCellEditor extends JVxCellEditor {
  dynamic selectedValue = true;
  dynamic deselectedValue = false;
  String text;

  JVxCheckboxCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    selectedValue = changedCellEditor.getProperty<dynamic>(
        CellEditorProperty.SELECTED_VALUE, selectedValue);
    deselectedValue = changedCellEditor.getProperty<dynamic>(
        CellEditorProperty.DESELECTED_VALUE, deselectedValue);
    text = changedCellEditor.getProperty<String>(CellEditorProperty.TEXT, text);
  }

  void valueChanged(dynamic value) {
    this.value = boolToValue(value);
    this.onValueChanged(this.value);
  }

  dynamic boolToValue(bool value) {
    if (value) return selectedValue;
    return deselectedValue;
  }

  bool valueToBool(dynamic value) {
    if (value != null && value == selectedValue) return true;
    return false;
  }

  @override
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    setEditorProperties(
        editable: editable,
        background: background,
        foreground: foreground,
        placeholder: placeholder,
        font: font,
        horizontalAlignment: horizontalAlignment);

    return Container(
      decoration: BoxDecoration(
          color: background != null ? background : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border:
              borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: valueToBool(this.value),
            onChanged: (bool change) => valueChanged(change),
            tristate: false,
          ),
          text != null
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          text != null ? Text(text) : Container(),
        ],
      ),
    );
  }
}
