import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/cell_editor.dart';
import 'package:jvx_flutterclient/model/properties/cell_editor_properties.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_cell_editor_widget.dart';
import 'package:jvx_flutterclient/utils/so_text_align.dart';
import 'package:jvx_flutterclient/utils/text_utils.dart';
import 'package:jvx_flutterclient/utils/uidata.dart';

import 'package:jvx_flutterclient/utils/globals.dart' as globals;

import 'cell_editor_model.dart';

class CoTextCellEditorWidget extends CoCellEditorWidget {
  CoTextCellEditorWidget(
      {Key key, CellEditor changedCellEditor, CellEditorModel cellEditorModel})
      : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel,
            key: key);

  @override
  State<StatefulWidget> createState() => CoTextCellEditorWidgetState();
}

class CoTextCellEditorWidgetState
    extends CoCellEditorWidgetState<CoTextCellEditorWidget> {
  TextEditingController _controller = TextEditingController();
  bool multiLine = false;
  bool password = false;
  bool valueChanged = false;

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

  @override
  void initState() {
    super.initState();
    multiLine = (widget.changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('multiline') ??
        false);
    password = (widget.changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('password') ??
        false);
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
    } else if (super.onEndEditing != null) {
      super.onEndEditing();
    }
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);

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
          controller: _controller,
          minLines: null,
          maxLines: multiLine ? null : 1,
          keyboardType:
              multiLine ? TextInputType.multiline : TextInputType.text,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          readOnly: !this.editable,
          obscureText: this.password
          //expands: this.verticalAlignment==1 && multiLine ? true : false,
          ),
    );
  }
}
