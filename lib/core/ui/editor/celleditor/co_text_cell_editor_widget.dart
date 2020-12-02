import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/app/so_text_align.dart';
import 'co_cell_editor_widget.dart';
import 'models/text_cell_editor_model.dart';

class CoTextCellEditorWidget extends CoCellEditorWidget {
  final TextCellEditorModel cellEditorModel;

  CoTextCellEditorWidget({Key key, this.cellEditorModel})
      : super(cellEditorModel: cellEditorModel, key: key);

  @override
  State<StatefulWidget> createState() => CoTextCellEditorWidgetState();
}

class CoTextCellEditorWidgetState
    extends CoCellEditorWidgetState<CoTextCellEditorWidget> {
  dynamic value;
  bool shouldShowSuffixIcon = false;

  void onTextFieldValueChanged(dynamic newValue) {
    if (value != newValue) {
      value = newValue;
      widget.cellEditorModel.valueChanged = true;

      if (newValue != null && newValue.isNotEmpty) {
        setState(() {
          shouldShowSuffixIcon = true;
        });
      }
    }
  }

  void onTextFieldEndEditing() {
    widget.cellEditorModel.focusNode.unfocus();

    if (widget.cellEditorModel.valueChanged) {
      widget.cellEditorModel
          .onValueChanged(context, value, widget.cellEditorModel.indexInTable);
      widget.cellEditorModel.valueChanged = false;
    } else if (super.onEndEditing != null) {
      super.onEndEditing();
    }
  }

  @override
  void initState() {
    super.initState();

    value = widget.cellEditorModel.cellEditorValue;

    widget.cellEditorModel.focusNode = FocusNode();
    widget.cellEditorModel.focusNode.addListener(() {
      if (!widget.cellEditorModel.focusNode.hasFocus) onTextFieldEndEditing();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (value != null && value.isNotEmpty) shouldShowSuffixIcon = true;

    return DecoratedBox(
      decoration: BoxDecoration(
          color: widget.cellEditorModel.background != null
              ? widget.cellEditorModel.background
              : Colors.white.withOpacity(widget.cellEditorModel.appState
                      .applicationStyle?.controlsOpacity ??
                  1.0),
          borderRadius: BorderRadius.circular(widget.cellEditorModel.appState
                  .applicationStyle?.cornerRadiusEditors ??
              10),
          border: widget.cellEditorModel.borderVisible &&
                  widget.cellEditorModel.editable != null &&
                  widget.cellEditorModel.editable
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        height: (widget.cellEditorModel.multiLine ? 100 : 50),
        child: TextField(
            textAlign: SoTextAlign.getTextAlignFromInt(
                widget.cellEditorModel.horizontalAlignment),
            decoration: InputDecoration(
                contentPadding: widget.cellEditorModel.textPadding,
                border: InputBorder.none,
                hintText: widget.cellEditorModel.placeholderVisible
                    ? widget.cellEditorModel.placeholder
                    : null,
                suffixIcon: widget.cellEditorModel.editable != null &&
                        widget.cellEditorModel.editable
                    ? Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            if (value != null && value.isNotEmpty) {
                              widget.cellEditorModel.textController.value =
                                  TextEditingValue(text: '');
                              widget.cellEditorModel.valueChanged = true;
                              widget.cellEditorModel.onValueChanged(context,
                                  null, widget.cellEditorModel.indexInTable);
                              widget.cellEditorModel.valueChanged = false;
                              setState(() {
                                value = null;
                              });
                            }
                          },
                          child: shouldShowSuffixIcon
                              ? Icon(Icons.clear,
                                  size: widget.cellEditorModel.iconSize,
                                  color: Colors.grey[400])
                              : SizedBox(
                                  height: widget.cellEditorModel.iconSize,
                                  width: 1),
                        ),
                      )
                    : null),
            style: TextStyle(
                color: widget.cellEditorModel.editable != null &&
                        widget.cellEditorModel.editable
                    ? (widget.cellEditorModel.foreground != null
                        ? widget.cellEditorModel.foreground
                        : Colors.black)
                    : Colors.grey[700]),
            controller: widget.cellEditorModel.textController,
            focusNode: widget.cellEditorModel.focusNode,
            minLines: null,
            maxLines: widget.cellEditorModel.multiLine ? null : 1,
            keyboardType: widget.cellEditorModel.multiLine
                ? TextInputType.multiline
                : TextInputType.text,
            onEditingComplete: onTextFieldEndEditing,
            onChanged: onTextFieldValueChanged,
            readOnly: widget.cellEditorModel.editable != null &&
                    !widget.cellEditorModel.editable ??
                false,
            obscureText: widget.cellEditorModel.password
            //expands: this.verticalAlignment==1 && multiLine ? true : false,
            ),
      ),
    );
  }
}
