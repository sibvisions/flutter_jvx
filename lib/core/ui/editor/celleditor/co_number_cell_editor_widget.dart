import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../utils/app/so_text_align.dart';
import 'co_cell_editor_widget.dart';
import 'formatter/numeric_text_formatter.dart';
import 'models/number_cell_editor_model.dart';

class CoNumberCellEditorWidget extends CoCellEditorWidget {
  final NumberCellEditorModel cellEditorModel;
  CoNumberCellEditorWidget({Key key, this.cellEditorModel})
      : super(key: key, cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoNumberCellEditorWidgetState();
}

class CoNumberCellEditorWidgetState
    extends CoCellEditorWidgetState<CoNumberCellEditorWidget> {
  bool shouldShowSuffixIcon = false;

  void onTextFieldValueChanged(dynamic newValue) {
    if (widget.cellEditorModel.tempValue != newValue) {
      widget.cellEditorModel.tempValue = newValue;
      widget.cellEditorModel.valueChanged = true;

      if (newValue != null && newValue.isNotEmpty) {
        setState(() {
          shouldShowSuffixIcon = true;
        });
      }
    }
  }

  void onTextFieldEndEditing() {
    NumberCellEditorModel cellEditorModel = widget.cellEditorModel;

    cellEditorModel.node.unfocus();

    if (cellEditorModel.valueChanged) {
      intl.NumberFormat format =
          intl.NumberFormat(cellEditorModel.numberFormat);
      if (cellEditorModel.tempValue.endsWith(format.symbols.DECIMAL_SEP))
        cellEditorModel.tempValue = cellEditorModel.tempValue
            .substring(0, cellEditorModel.tempValue.length - 1);
      cellEditorModel.cellEditorValue = NumericTextFormatter.convertToNumber(
          cellEditorModel.tempValue, cellEditorModel.numberFormat, format);
      super.onValueChanged(context, cellEditorModel.cellEditorValue);
      cellEditorModel.valueChanged = false;
    }
  }

  @override
  void initState() {
    super.initState();

    widget.cellEditorModel.node.addListener(() {
      if (!widget.cellEditorModel.node.hasFocus) onTextFieldEndEditing();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextDirection direction = TextDirection.ltr;

    if (widget.cellEditorModel.tempValue != null &&
        widget.cellEditorModel.tempValue.isNotEmpty)
      shouldShowSuffixIcon = true;

    return DecoratedBox(
      decoration: BoxDecoration(
          color: widget.cellEditorModel.background != null
              ? widget.cellEditorModel.background
              : widget.cellEditorModel.appState.applicationStyle != null
                  ? Colors.white.withOpacity(widget.cellEditorModel.appState
                      .applicationStyle?.controlsOpacity)
                  : null,
          borderRadius: BorderRadius.circular(widget
              .cellEditorModel.appState.applicationStyle?.cornerRadiusEditors),
          border: widget.cellEditorModel.borderVisible &&
                  widget.cellEditorModel.editable != null &&
                  widget.cellEditorModel.editable
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        child: TextFormField(
          textAlign: SoTextAlign.getTextAlignFromInt(
              widget.cellEditorModel.horizontalAlignment),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: widget.cellEditorModel.placeholder,
              suffixIcon: widget.cellEditorModel.editable
                  ? Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.cellEditorModel.tempValue != null) {
                            widget.cellEditorModel.tempValue = null;
                            widget.cellEditorModel.valueChanged = true;
                            super.onValueChanged(context,
                                widget.cellEditorModel.cellEditorValue);
                            widget.cellEditorModel.valueChanged = false;
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
              color: widget.cellEditorModel.editable
                  ? (widget.cellEditorModel.foreground != null
                      ? widget.cellEditorModel.foreground
                      : Colors.black)
                  : Colors.grey[700]),
          controller: widget.cellEditorModel.controller,
          focusNode: widget.cellEditorModel.node,
          keyboardType: widget.cellEditorModel.textInputType,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          textDirection: direction,
          inputFormatters: widget.cellEditorModel.textInputFormatter,
          enabled: widget.cellEditorModel.editable,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // (widget.cellEditorModel as NumberCellEditorModel).node.dispose();

    super.dispose();
  }
}
