import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxTextCellEditor extends JVxCellEditor {
  TextEditingController _controller = TextEditingController();
  bool multiLine = false;
  bool valueChanged = false;
  FocusNode node = FocusNode();

  JVxTextCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    multiLine = (changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('multiline') ??
        false);
    node.addListener(() {
      if (!node.hasFocus) onTextFieldEndEditing();
    });
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (this.value != newValue) {
      this.value = newValue;
      this.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      super.onValueChanged(this.value);
      this.valueChanged = false;
    }
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
    _controller.text = (this.value != null ? this.value.toString() : "");

    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: this.background != null ? this.background : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border:
              borderVisible && this.editable ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: TextField(
        style: TextStyle(color: this.foreground != null ? this.foreground : Colors.black),
        decoration: InputDecoration(
            fillColor: this.background != null ? this.background : Colors.transparent,
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.0))),
        key: this.key,
        controller: _controller,
        maxLines: multiLine ? 4 : 1,
        keyboardType: multiLine ? TextInputType.multiline : TextInputType.text,
        onEditingComplete: onTextFieldEndEditing,
        onChanged: onTextFieldValueChanged,
        focusNode: node,
        enabled: this.editable,
      ),
    );
  }
}
