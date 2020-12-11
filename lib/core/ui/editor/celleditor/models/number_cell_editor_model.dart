import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../models/api/response/meta_data/data_book_meta_data_column.dart';
import '../../../../utils/app/text_utils.dart';
import '../../../screen/so_component_data.dart';
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
  NumericTextFormatter numericTextFormatter;
  List<TextInputFormatter> textInputFormatter = List<TextInputFormatter>();
  TextInputType textInputType;
  String tempValue;
  FocusNode node = FocusNode();

  @override
  set data(SoComponentData newData) {
    super.data = newData;
    updateMetadataNumberformat();
  }

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
    this.tempValue = numericTextFormatter.getFormattedString(value);
    this.controller.value = TextEditingValue(text: this.tempValue ?? '');
    super.cellEditorValue = value;
  }

  NumberCellEditorModel(CellEditor cellEditor) : super(cellEditor) {
    numberFormat =
        this.cellEditor.getProperty<String>(CellEditorProperty.NUMBER_FORMAT);

    if (this.numberFormat != null && this.numberFormat.isNotEmpty) {
      this.numericTextFormatter =
          NumericTextFormatter(this.numberFormat, this.appState.language);
      textInputFormatter.add(this.numericTextFormatter);
    }
  }

  void updateMetadataNumberformat() {
    if (this.columnName != null && this.numericTextFormatter != null) {
      if (this.data?.metaData != null) {
        DataBookMetaDataColumn column =
            this.data.metaData.getColumn(this.columnName);

        if (column?.cellEditor != null) {
          this.numericTextFormatter.precision =
              column.cellEditor.getProperty<int>(CellEditorProperty.PRECISION);
          this.numericTextFormatter.length =
              column.cellEditor.getProperty<int>(CellEditorProperty.LENGTH);
          this.numericTextFormatter.scale =
              column.cellEditor.getProperty<int>(CellEditorProperty.SCALE);
          this.numericTextFormatter.signed =
              column.cellEditor.getProperty<bool>(CellEditorProperty.SIGNED);
        }
      }
    }
  }
}
