import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_align.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxTextCellEditor extends JVxCellEditor {
  TextEditingController _controller = TextEditingController();
  bool multiLine = false;
  bool valueChanged = false;
  FocusNode node = FocusNode();

  @override
  get preferredSize {
    if (multiLine)
      return Size(200, 100);
    else
      return Size(200, 50);
  }

  @override
  get minimumSize {
    return Size(10, 50);
  }

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
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

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
    String controllerValue = (this.value != null ? this.value.toString() : "");
    _controller.value = _controller.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return DecoratedBox(
      decoration: BoxDecoration(
          color: this.background != null ? this.background : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: borderVisible && this.editable != null && this.editable
              ? Border.all(color: UIData.ui_kit_color_2)
              : Border.all(color: Colors.grey)),
      child: TextField(
        //textAlignVertical: JVxTextAlignVertical.getTextAlignFromInt(this.verticalAlignment),
        textAlign: JVxTextAlign.getTextAlignFromInt(this.horizontalAlignment),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 12, right: 12),
          border: InputBorder.none
        ),
        style: TextStyle(
            color: this.editable ? (this.foreground != null ? this.foreground : Colors.black) : Colors.grey[700]),
        key: this.key,
        controller: _controller,
        minLines: null,
        maxLines: multiLine ? null : 1,
        keyboardType: multiLine ? TextInputType.multiline : TextInputType.text,
        onEditingComplete: onTextFieldEndEditing,
        onChanged: onTextFieldValueChanged,
        focusNode: node,
        readOnly: !this.editable,
        //expands: this.verticalAlignment==1 && multiLine ? true : false,
      ),
    );
  }
}
