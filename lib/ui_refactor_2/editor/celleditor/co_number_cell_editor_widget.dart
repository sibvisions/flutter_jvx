import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jvx_flutterclient/model/cell_editor.dart';
import 'package:jvx_flutterclient/model/properties/cell_editor_properties.dart';
import 'package:jvx_flutterclient/ui/editor/celleditor/formatter/numeric_text_formatter.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_cell_editor_widget.dart';
import 'package:jvx_flutterclient/utils/so_text_align.dart';
import 'package:jvx_flutterclient/utils/text_utils.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jvx_flutterclient/utils/globals.dart' as globals;
import 'package:jvx_flutterclient/utils/uidata.dart';

import '../co_editor_widget.dart';

class CoNumberCellEditorWidget extends CoCellEditorWidget {
  CoNumberCellEditorWidget({Key key, CellEditor changedCellEditor})
      : super(key: key, changedCellEditor: changedCellEditor);

  @override
  State<StatefulWidget> createState() => CoNumberCellEditorWidgetState();
}

class CoNumberCellEditorWidgetState
    extends CoCellEditorWidgetState<CoNumberCellEditorWidget> {
  TextEditingController _controller = TextEditingController();
  bool valueChanged = false;
  String numberFormat;
  List<TextInputFormatter> textInputFormatter;
  TextInputType textInputType;
  String tempValue;

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button)
        .toDouble();
    return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  @override
  set value(dynamic pValue) {
    super.value = pValue;
    this.tempValue = _getFormattedValue();
    _controller.text = this.tempValue;
  }

  String _getFormattedValue() {
    if (this.value != null && (this.value is int || this.value is double)) {
      if (numberFormat != null && numberFormat.isNotEmpty) {
        intl.NumberFormat format = intl.NumberFormat(numberFormat);
        return format.format(this.value);
      }

      return this.value;
    }

    return "";
  }

  void onTextFieldValueChanged(dynamic newValue) {
    this.tempValue = newValue;
    this.valueChanged = true;
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      intl.NumberFormat format = intl.NumberFormat(numberFormat);
      if (tempValue.endsWith(format.symbols.DECIMAL_SEP))
        tempValue = tempValue.substring(0, tempValue.length - 1);
      this.value =
          NumericTextFormatter.convertToNumber(tempValue, numberFormat, format);
      super.onValueChanged(this.value);
      this.valueChanged = false;
    }
  }

  List<TextInputFormatter> getImputFormatter() {
    List<TextInputFormatter> formatter = List<TextInputFormatter>();
    if (numberFormat != null && numberFormat.isNotEmpty)
      formatter.add(NumericTextFormatter(numberFormat)); //globals.language));

    return formatter;
  }

  TextInputType getKeyboardType() {
    if (numberFormat != null && numberFormat.isNotEmpty) {
      if (!numberFormat.contains(".")) return TextInputType.number;
    }

    return TextInputType.numberWithOptions(decimal: true);
  }

  @override
  void initState() {
    super.initState();
    numberFormat = widget.changedCellEditor
        .getProperty<String>(CellEditorProperty.NUMBER_FORMAT);

    /// ToDo intl Number Formatter only supports only patterns with up to 16 digits
    if (numberFormat != null) {
      List<String> numberFormatParts = numberFormat.split(".");
      if (numberFormatParts.length > 1 && numberFormatParts[1].length > 14) {
        numberFormat =
            numberFormatParts[0] + "." + numberFormatParts[1].substring(0, 14);
      }
    }

    textInputFormatter = this.getImputFormatter();
    textInputType = this.getKeyboardType();
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);
    TextDirection direction = TextDirection.ltr;

    return DecoratedBox(
      decoration: BoxDecoration(
          color: this.background != null
              ? this.background
              : Colors.white
                  .withOpacity(globals.applicationStyle.controlsOpacity),
          borderRadius: BorderRadius.circular(
              globals.applicationStyle.cornerRadiusEditors),
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
                      child:
                          Icon(Icons.clear, size: 24, color: Colors.grey[400]),
                    ),
                  )
                : null),
        style: TextStyle(
            color: this.editable
                ? (this.foreground != null ? this.foreground : Colors.black)
                : Colors.grey[700]),
        controller: _controller,
        keyboardType: textInputType,
        onEditingComplete: onTextFieldEndEditing,
        onChanged: onTextFieldValueChanged,
        textDirection: direction,
        inputFormatters: textInputFormatter,
        enabled: this.editable,
      ),
    );
  }
}
