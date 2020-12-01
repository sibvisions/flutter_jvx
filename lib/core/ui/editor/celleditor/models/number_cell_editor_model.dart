import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../utils/app/text_utils.dart';
import '../formatter/numeric_text_formatter.dart';
import 'cell_editor_model.dart';

class NumberCellEditorModel extends CellEditorModel {
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.fromLTRB(12, 15, 12, 5);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);
  TextStyle style;
  TextEditingController controller = TextEditingController();
  bool valueChanged = false;
  String numberFormat;
  List<TextInputFormatter> textInputFormatter;
  TextInputType textInputType;
  String tempValue;
  FocusNode node = FocusNode();

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    String text = TextUtils.averageCharactersTextField;

    if (numberFormat != null && numberFormat.length < text.length)
      text = text.substring(0, numberFormat?.length);

    if (cellEditorValue != null && cellEditorValue.toString().length > 0) {
      text = cellEditorValue.toString();
    }

    double width = TextUtils.getTextWidth(text, fontStyle).toDouble();

    // print("NumberCellEditor PreferredSize: " +
    //     Size(18 + width + iconWidth + textPadding.horizontal, 50).toString() +
    //     "(" +
    //     text +
    //     ")");

    return Size(width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    return preferredSize;
    //double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    //return Size(10 + iconWidth + textPadding.horizontal, 100);
  }

  @override
  set cellEditorValue(value) {
    this.tempValue = _getFormattedValue(value);
    this.controller.value = TextEditingValue(text: this.tempValue ?? '');
    super.cellEditorValue = value;
  }

  NumberCellEditorModel(CellEditor cellEditor) : super(cellEditor) {
    numberFormat =
        this.cellEditor.getProperty<String>(CellEditorProperty.NUMBER_FORMAT);

    /// ToDo intl Number Formatter only supports only patterns with up to 16 digits
    /// textInputFormatter = this.getImputFormatter();
    if (numberFormat != null) {
      List<String> numberFormatParts = numberFormat.split(".");
      if (numberFormatParts.length > 1 && numberFormatParts[1].length > 14) {
        numberFormat =
            numberFormatParts[0] + "." + numberFormatParts[1].substring(0, 14);
      }
    }

    textInputType = this.getKeyboardType();
  }

  String _getFormattedValue(dynamic value) {
    if (value != null && (value is int || value is double)) {
      if (numberFormat != null && numberFormat.isNotEmpty) {
        intl.NumberFormat format = intl.NumberFormat(numberFormat);
        return format.format(value);
      }

      return value;
    }

    return "";
  }

  TextInputType getKeyboardType() {
    if (this.numberFormat != null && this.numberFormat.isNotEmpty) {
      if (!this.numberFormat.contains(".")) return TextInputType.number;
    }

    return TextInputType.numberWithOptions(decimal: true);
  }

  List<TextInputFormatter> getImputFormatter() {
    List<TextInputFormatter> formatter = List<TextInputFormatter>();
    if (this.numberFormat != null && this.numberFormat.isNotEmpty)
      formatter
          .add(NumericTextFormatter(this.numberFormat)); //globals.language));

    return formatter;
  }
}
