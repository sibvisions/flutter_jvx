import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../utils/app/so_text_align.dart';
import 'co_cell_editor_widget.dart';
import 'text_cell_editor_model.dart';

class CoTextCellEditorWidget extends CoCellEditorWidget {
  final TextCellEditorModel cellEditorModel;

  CoTextCellEditorWidget(
      {Key key, CellEditor changedCellEditor, this.cellEditorModel})
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
  bool password = false;
  bool valueChanged = false;
  final GlobalKey textfieldKey = GlobalKey<CoTextCellEditorWidgetState>();
  FocusNode node = FocusNode();

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
  void initState() {
    super.initState();
    widget.cellEditorModel.multiLine = (widget.changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('multiline') ??
        false);
    password = (widget.changedCellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('password') ??
        false);
    this.node.addListener(() {
      if (!node.hasFocus) onTextFieldEndEditing();
    });
  }

  @override
  void dispose() {
    node.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  this.appState.applicationStyle?.controlsOpacity ?? 1.0),
          borderRadius: BorderRadius.circular(
              this.appState.applicationStyle?.cornerRadiusEditors ?? 10),
          border: borderVisible && this.editable != null && this.editable
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        child: TextField(
            textAlign:
                SoTextAlign.getTextAlignFromInt(this.horizontalAlignment),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(12, 15, 12, 5),
                border: InputBorder.none,
                hintText: placeholderVisible ? placeholder : null,
                suffixIcon: this.editable != null &&
                        this.editable &&
                        this._controller.text.isNotEmpty
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
                color: this.editable != null && this.editable
                    ? (this.foreground != null ? this.foreground : Colors.black)
                    : Colors.grey[700]),
            controller: _controller,
            focusNode: node,
            minLines: null,
            maxLines: widget.cellEditorModel.multiLine ? null : 1,
            keyboardType: widget.cellEditorModel.multiLine
                ? TextInputType.multiline
                : TextInputType.text,
            onEditingComplete: onTextFieldEndEditing,
            onChanged: onTextFieldValueChanged,
            readOnly: this.editable != null && !this.editable ?? false,
            obscureText: this.password
            //expands: this.verticalAlignment==1 && multiLine ? true : false,
            ),
      ),
    );
  }
}
