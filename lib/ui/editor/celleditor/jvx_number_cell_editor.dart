import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/formatter/numeric_text_formatter.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/layout/i_alignment_constants.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxNumberCellEditor extends JVxCellEditor {
  TextEditingController _controller = TextEditingController();
  bool multiLine = false;
  bool valueChanged = false;
  String numberFormat;
  
  JVxNumberCellEditor(CellEditor changedCellEditor, BuildContext context) : super(changedCellEditor, context) {
      numberFormat = changedCellEditor.getProperty<String>(CellEditorProperty.NUMBER_FORMAT);
  }

  void onTextFieldValueChanged(dynamic newValue) {
    this.value = newValue;
    this.valueChanged = true;
  }

  void onTextFieldEndEditing() {
    if (this.valueChanged) {
      super.onValueChanged(this.value);
      this.valueChanged = false;
    }
  }

  List<TextInputFormatter> getImputFormatter() {
    List<TextInputFormatter> formatter = List<TextInputFormatter>();
    if (numberFormat!=null && numberFormat.isNotEmpty) 
    formatter.add(NumericTextFormatter(intl.NumberFormat(numberFormat, globals.language)));

    return  formatter;
  }

  String getFormattedValue() {
    if (this.value!=null) {
      if (numberFormat!=null && numberFormat.isNotEmpty) {
        intl.NumberFormat format = intl.NumberFormat(numberFormat, globals.language);
        return format.format(Properties.utf8convert(this.value));
      }

      return Properties.utf8convert(this.value);
    } 

    return "";
  }
  
  @override
  Widget getWidget() {
    TextDirection direction = TextDirection.ltr;

    if (horizontalAlignment==IAlignmentConstants.ALIGN_RIGHT)
      direction = TextDirection.rtl;

    _controller.text = getFormattedValue();

    return TextField(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 0.0)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 0.0)
        ),
      ),
      key: this.key,
      controller: _controller,
      maxLines: multiLine ? 4 : 1,
      keyboardType: TextInputType.number,
      onEditingComplete: onTextFieldEndEditing,
      onChanged: onTextFieldValueChanged,
      textDirection: direction,
      inputFormatters: getImputFormatter(),
    );
  }
}