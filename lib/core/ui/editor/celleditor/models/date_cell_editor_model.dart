import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../utils/app/text_utils.dart';
import 'cell_editor_model.dart';

class DateCellEditorModel extends CellEditorModel {
  String dateFormat;

  DateCellEditorModel(CellEditor currentCellEditor) : super(currentCellEditor) {
    dateFormat = this
        .currentCellEditor
        .getProperty<String>(CellEditorProperty.DATE_FORMAT);

    if (dateFormat.contains('Y')) dateFormat = dateFormat.replaceAll('Y', 'y');
  }

  @override
  get preferredSize {
    String text = DateFormat(this.dateFormat)
        .format(DateTime.parse("2020-12-31 22:22:22Z"));

    if (text.isEmpty) text = TextUtils.averageCharactersDateField;

    double width = TextUtils.getTextWidth(text, fontStyle).toDouble();
    return Size(width + 110, 50);
  }

  @override
  get minimumSize {
    return Size(110, 50);
  }

  @override
  get tableMinimumSize {
    return this.preferredSize;
  }
}
