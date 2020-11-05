import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/cell_editor.dart';
import 'package:jvx_flutterclient/model/properties/cell_editor_properties.dart';
import 'package:jvx_flutterclient/utils/text_utils.dart';
import 'package:intl/intl.dart';

import '../../editor/celleditor/cell_editor_model.dart';

class DateCellEditorModel extends CellEditorModel {
  String dateFormat;
  BuildContext context;

  DateCellEditorModel(this.context, CellEditor currentCellEditor)
      : super(currentCellEditor) {
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

    double width =
        TextUtils.getTextWidth(text, Theme.of(context).textTheme.bodyText1)
            .toDouble();
    return Size(width + 105, 50);
  }

  @override
  get minimumSize {
    return Size(103, 50);
  }

  @override
  get tableMinimumSize {
    return this.preferredSize;
  }
}
