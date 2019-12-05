import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/formatter/numeric_text_formatter.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/layout/i_alignment_constants.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxNumberCellEditor extends JVxCellEditor {
  TextEditingController _controller = TextEditingController();
  bool valueChanged = false;
  String numberFormat;
  List<TextInputFormatter> textInputFormatter;
  TextInputType textInputType;
  String tempValue;

  @override
  set value(dynamic pValue) {
    super.value = pValue;
    this.tempValue = getFormattedValue();
    _controller.text = this.tempValue;
  }

  JVxNumberCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    numberFormat =
        changedCellEditor.getProperty<String>(CellEditorProperty.NUMBER_FORMAT);

    /// ToDo intl Number Formatter only supports only patterns with up to 16 digits
    if (numberFormat != null) {
      List<String> numberFormatParts = numberFormat.split(".");
      if (numberFormatParts.length > 1 && numberFormatParts[1].length > 16) {
        numberFormat =
            numberFormatParts[0] + "." + numberFormatParts[1].substring(0, 16);
      }
    }

    textInputFormatter = this.getImputFormatter();
    textInputType = this.getKeyboardType();
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
          NumericTextFormatter.convertToNumber(tempValue, numberFormat);
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

  String getFormattedValue() {
    if (this.value != null && (this.value is int || this.value is double)) {
      if (numberFormat != null && numberFormat.isNotEmpty) {
        intl.NumberFormat format = intl.NumberFormat(numberFormat);
        return format.format(this.value);
      }

      return this.value;
    }

    return "";
  }

  TextInputType getKeyboardType() {
    if (numberFormat != null && numberFormat.isNotEmpty) {
      if (!numberFormat.contains(".")) return TextInputType.number;
    }

    return TextInputType.numberWithOptions(decimal: true);
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
    TextDirection direction = TextDirection.ltr;

    //if (horizontalAlignment==IAlignmentConstants.ALIGN_RIGHT)
    //  direction = TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
          color: background != null ? background : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border:
              borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: TextField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
        ),
        key: this.key,
        controller: _controller,
        keyboardType: textInputType,
        onEditingComplete: onTextFieldEndEditing,
        onChanged: onTextFieldValueChanged,
        textDirection: direction,
        inputFormatters: textInputFormatter,
      ),
    );
  }
}
