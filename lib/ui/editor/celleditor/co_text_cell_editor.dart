import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import '../../../utils/text_utils.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import 'co_cell_editor.dart';
import '../../../utils/so_text_align.dart';
import '../../../utils/uidata.dart';
import '../../../utils/globals.dart' as globals;

class CoTextCellEditor extends CoCellEditor {
  TextEditingController _controller = TextEditingController();
  bool multiLine = false;
  bool password = false;
  bool valueChanged = false;
  FocusNode node = FocusNode();

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button)
        .toDouble();
    if (multiLine)
      return Size(width, 100);
    else
      return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(10, 50);
  }

  CoTextCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    multiLine = (changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('multiline') ??
        false);
    password = (changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('password') ??
        false);
    node.addListener(() {
      if (!node.hasFocus) onTextFieldEndEditing();
    });
  }

  factory CoTextCellEditor.withCompContext(ComponentContext componentContext) {
    return CoTextCellEditor(
        componentContext.cellEditor, componentContext.context);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (this.value != newValue) {
      this.value = newValue;
      this.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    node.unfocus();

    if (this.valueChanged) {
      super.onValueChanged(this.value);
      this.valueChanged = false;
    } else if (super.onEndEditing != null) {
      super.onEndEditing();
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
          color: this.background != null
              ? this.background
              : Colors.white.withOpacity(
                  globals.applicationStyle?.controlsOpacity ?? 1.0),
          borderRadius: BorderRadius.circular(
              globals.applicationStyle?.cornerRadiusEditors ?? 10),
          border: borderVisible && this.editable != null && this.editable
              ? Border.all(color: UIData.ui_kit_color_2)
              : Border.all(color: Colors.grey)),
      child: TextField(
          textAlign: SoTextAlign.getTextAlignFromInt(this.horizontalAlignment),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: placeholderVisible ? placeholder : null,
              suffixIcon: this.editable
                  ? Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (this.value != null) {
                            this.value = null;
                            this.valueChanged = true;
                            super.onValueChanged(this.value);
                            this.valueChanged = false;
                            node.unfocus();
                          }
                        },
                        child: Icon(Icons.clear,
                            size: 24, color: Colors.grey[400]),
                      ),
                    )
                  : null),
          style: TextStyle(
              color: this.editable
                  ? (this.foreground != null ? this.foreground : Colors.black)
                  : Colors.grey[700]),
          key: this.key,
          controller: _controller,
          minLines: null,
          maxLines: multiLine ? null : 1,
          keyboardType:
              multiLine ? TextInputType.multiline : TextInputType.text,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          focusNode: node,
          readOnly: !this.editable,
          obscureText: this.password
          //expands: this.verticalAlignment==1 && multiLine ? true : false,
          ),
    );
  }
}
