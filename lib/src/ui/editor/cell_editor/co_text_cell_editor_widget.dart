import 'package:flutter/material.dart';

import '../../../util/app/so_text_align.dart';
import 'co_cell_editor_widget.dart';
import 'models/text_cell_editor_model.dart';

class CoTextCellEditorWidget extends CoCellEditorWidget {
  final TextCellEditorModel cellEditorModel;

  CoTextCellEditorWidget({required this.cellEditorModel})
      : super(cellEditorModel: cellEditorModel);

  @override
  CoCellEditorWidgetState<CoCellEditorWidget> createState() =>
      CoTextCellEditorWidgetState();
}

class CoTextCellEditorWidgetState
    extends CoCellEditorWidgetState<CoTextCellEditorWidget> {
  dynamic? value;
  bool shouldShowSuffixIcon = false;
  bool obsureText = true;

  Color get backgroundColor =>
      widget.cellEditorModel.backgroundColor ?? Colors.white;

  Border get textFieldBorder {
    if (widget.cellEditorModel.borderVisible &&
        widget.cellEditorModel.editable) {
      return Border.all(color: Theme.of(context).primaryColor);
    }

    return Border.all(color: Colors.grey);
  }

  Widget? get suffixIcon {
    if (widget.cellEditorModel.editable && shouldShowSuffixIcon) {
      return GestureDetector(
        onTap: () {
          if (value != null && value.isNotEmpty) {
            onTextFieldValueChanged('');
            onTextFieldEndEditing();
          }
        },
        child: Icon(
          Icons.clear,
          size: widget.cellEditorModel.iconSize,
          color: Colors.grey[400],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SizedBox(
          height: widget.cellEditorModel.iconSize,
          width: 1,
        ),
      );
    }
  }

  TextStyle get textStyle {
    if (widget.cellEditorModel.editable) {
      if (widget.cellEditorModel.foregroundColor != null) {
        return TextStyle(color: widget.cellEditorModel.foregroundColor);
      } else {
        return TextStyle(color: Colors.black);
      }
    } else {
      return TextStyle(color: Colors.grey[700]);
    }
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (value != newValue) {
      if (newValue != null &&
          newValue.isNotEmpty &&
          (value == null || value.isEmpty)) {
        setState(() {
          shouldShowSuffixIcon = true;
        });
      } else if ((newValue == null || newValue.isEmpty) &&
          value != null &&
          value.isNotEmpty) {
        setState(() {
          shouldShowSuffixIcon = false;
        });
      }

      value = newValue;
      widget.cellEditorModel.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    widget.cellEditorModel.focusNode.unfocus();

    if (widget.cellEditorModel.valueChanged &&
        widget.cellEditorModel.onValueChanged != null) {
      widget.cellEditorModel.onValueChanged!(
          context, value, widget.cellEditorModel.indexInTable);
      widget.cellEditorModel.valueChanged = false;
    } else if (super.onEndEditing != null) {
      super.onEndEditing!();
    }
  }

  void _focusListener() {
    widget.cellEditorModel.hasFocus = widget.cellEditorModel.focusNode.hasFocus;
    if (!widget.cellEditorModel.hasFocus) onTextFieldEndEditing();
  }

  void onCellEditorValueChanged() {
    value = widget.cellEditorModel.cellEditorValue;
  }

  @override
  void initState() {
    super.initState();

    value = widget.cellEditorModel.cellEditorValue;
    widget.cellEditorModel.focusNode = FocusNode();
    widget.cellEditorModel.focusNode.addListener(_focusListener);

    widget.cellEditorModel.addListener(onCellEditorValueChanged);

    if (widget.cellEditorModel.multiLine) {
      widget.cellEditorModel.textPadding =
          const EdgeInsets.only(left: 12, top: 10);
    }
  }

  @override
  void dispose() {
    widget.cellEditorModel.focusNode.removeListener(_focusListener);
    widget.cellEditorModel.removeListener(onCellEditorValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (value != null && value.isNotEmpty) shouldShowSuffixIcon = true;

    if (widget.cellEditorModel.hasFocus &&
        !widget.cellEditorModel.focusNode.hasFocus)
      widget.cellEditorModel.focusNode.requestFocus();

    return DecoratedBox(
      decoration: BoxDecoration(
          color: backgroundColor.withOpacity(widget
              .cellEditorModel.appState.applicationStyle!.controlsOpacity),
          borderRadius: BorderRadius.circular(widget
              .cellEditorModel.appState.applicationStyle!.cornerRadiusEditors),
          border: textFieldBorder),
      child: Container(
        width: 100,
        height: (widget.cellEditorModel.multiLine ? 100 : 50),
        child: TextFormField(
          textAlign: SoTextAlign.getTextAlignFromInt(
              widget.cellEditorModel.horizontalAlignment),
          textAlignVertical: SoTextAlignVertical.getTextAlignFromInt(
              widget.cellEditorModel.verticalAlignment),
          decoration: InputDecoration(
              contentPadding: widget.cellEditorModel.textPadding,
              border: InputBorder.none,
              hintText: widget.cellEditorModel.placeholder,
              suffixIcon: widget.cellEditorModel.password
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          obsureText = !obsureText;
                        });
                      },
                      child: Icon(
                        obsureText ? Icons.visibility : Icons.visibility_off,
                      ),
                    )
                  : suffixIcon),
          style: textStyle,
          controller: widget.cellEditorModel.textController,
          focusNode: widget.cellEditorModel.focusNode,
          maxLines: widget.cellEditorModel.multiLine ? null : 1,
          keyboardType: widget.cellEditorModel.multiLine
              ? TextInputType.multiline
              : TextInputType.text,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          readOnly: !widget.cellEditorModel.editable,
          obscureText: widget.cellEditorModel.password ? obsureText : false,
        ),
      ),
    );
  }
}
