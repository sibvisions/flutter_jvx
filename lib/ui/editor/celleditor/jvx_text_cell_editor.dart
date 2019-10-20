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
  
  JVxTextCellEditor(CellEditor changedCellEditor, BuildContext context) : super(changedCellEditor, context) {
    multiLine = (changedCellEditor.getProperty<String>(CellEditorProperty.CONTENT_TYPE)?.contains('multiline') ?? false);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    this.value = newValue;
    this.valueChanged = true;
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      super.onValueChanged(this.value);
      this.valueChanged = false;
    }
  }
  
  @override
  Widget getWidget() {
    _controller.text = (this.value!=null ? Properties.utf8convert(this.value.toString()) : "");
    
    return TextField(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 0.0)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 0.0)
        ),
      ),
      key: this.key,
      controller: _controller,
      maxLines: multiLine ? 4 : 1,
      keyboardType: multiLine ? TextInputType.multiline : TextInputType.text,
      onEditingComplete: onTextFieldEndEditing,
      onChanged: onTextFieldValueChanged,
    );
  }
}