import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import '../../../utils/jvx_text_align.dart';
import '../../../utils/text_utils.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import '../../../ui/editor/celleditor/formatter/numeric_text_formatter.dart';
import '../../../ui/editor/celleditor/jvx_cell_editor.dart';
import '../../../utils/uidata.dart';
import '../../../utils/globals.dart' as globals;

class JVxNumberCellEditor extends JVxCellEditor {
  TextEditingController _controller = TextEditingController();
  bool valueChanged = false;
  String numberFormat;
  List<TextInputFormatter> textInputFormatter;
  TextInputType textInputType;
  String tempValue;

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField, Theme.of(context).textTheme.button).toDouble();
    return Size(width,50);
  }

  @override
  get minimumSize {
    return Size(50,50);
  }

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
      if (numberFormatParts.length > 1 && numberFormatParts[1].length > 14) {
        numberFormat =
            numberFormatParts[0] + "." + numberFormatParts[1].substring(0, 14);
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

    return DecoratedBox(
      decoration: BoxDecoration(
          color: this.background != null ? this.background : Colors.white.withOpacity(globals.applicationStyle.controlsOpacity),
          borderRadius: BorderRadius.circular(5),
          border: borderVisible && this.editable != null && this.editable
              ? Border.all(color: UIData.ui_kit_color_2)
              : Border.all(color: Colors.grey)),
      child: TextField(
        //textAlignVertical: JVxTextAlignVertical.getTextAlignFromInt(this.verticalAlignment),
        textAlign: JVxTextAlign.getTextAlignFromInt(this.horizontalAlignment),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12),
          border: InputBorder.none
        ),
        style: TextStyle(
            color: this.editable ? (this.foreground != null ? this.foreground : Colors.black) : Colors.grey[700]),
        key: this.key,
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
