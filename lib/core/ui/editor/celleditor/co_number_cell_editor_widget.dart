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
  void onTextFieldValueChanged(dynamic newValue) {
    (widget.cellEditorModel as NumberCellEditorModel).tempValue = newValue;
    (widget.cellEditorModel as NumberCellEditorModel).valueChanged = true;
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

    (widget.cellEditorModel as NumberCellEditorModel).node.addListener(() {
      if (!(widget.cellEditorModel as NumberCellEditorModel).node.hasFocus)
        onTextFieldEndEditing();
    });
  }

  @override
  Widget build(BuildContext context) {
    NumberCellEditorModel cellEditorModel = widget.cellEditorModel;

    TextDirection direction = TextDirection.ltr;

    return DecoratedBox(
      decoration: BoxDecoration(
          color: cellEditorModel.background != null
              ? cellEditorModel.background
              : cellEditorModel.appState.applicationStyle != null
                  ? Colors.white.withOpacity(cellEditorModel
                      .appState.applicationStyle?.controlsOpacity)
                  : null,
          borderRadius: BorderRadius.circular(
              cellEditorModel.appState.applicationStyle?.cornerRadiusEditors),
          border: cellEditorModel.borderVisible &&
                  cellEditorModel.editable != null &&
                  cellEditorModel.editable
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        child: TextFormField(
          textAlign: SoTextAlign.getTextAlignFromInt(
              cellEditorModel.horizontalAlignment),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: cellEditorModel.placeholderVisible
                  ? cellEditorModel.placeholder
                  : null,
              suffixIcon: cellEditorModel.editable
                  ? Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (cellEditorModel.cellEditorValue != null) {
                            cellEditorModel.cellEditorValue = null;
                            cellEditorModel.valueChanged = true;
                            super.onValueChanged(
                                context, cellEditorModel.cellEditorValue);
                            cellEditorModel.valueChanged = false;
                          }
                        },
                        child: cellEditorModel.cellEditorValue != null &&
                                cellEditorModel.cellEditorValue
                                    .toString()
                                    .isNotEmpty
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
              color: cellEditorModel.editable
                  ? (cellEditorModel.foreground != null
                      ? cellEditorModel.foreground
                      : Colors.black)
                  : Colors.grey[700]),
          controller: cellEditorModel.controller,
          focusNode: cellEditorModel.node,
          keyboardType: cellEditorModel.textInputType,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          textDirection: direction,
          inputFormatters: cellEditorModel.textInputFormatter,
          enabled: cellEditorModel.editable,
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
