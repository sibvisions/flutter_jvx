import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../utils/app/text_utils.dart';
import 'cell_editor_model.dart';

class DateCellEditorModel extends CellEditorModel {
  String dateFormat;
  dynamic toUpdate;

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

  get isTimeFormat {
    return this.dateFormat.contains("H") || this.dateFormat.contains("m");
  }

  get isDateFormat {
    return this.dateFormat.contains("d") ||
        this.dateFormat.contains("M") ||
        this.dateFormat.contains("y");
  }

  DateCellEditorModel(CellEditor cellEditor) : super(cellEditor) {
    preferredEditorMode = this
        .cellEditor
        .getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);

    dateFormat =
        this.cellEditor.getProperty<String>(CellEditorProperty.DATE_FORMAT);

    if (dateFormat.contains('Y')) dateFormat = dateFormat.replaceAll('Y', 'y');
  }

  void setDatePart(DateTime date) {
    DateTime timePart;
    if (this.toUpdate == null)
      timePart = DateTime(1970);
    else {
      if (this.toUpdate is int)
        timePart = DateTime.fromMillisecondsSinceEpoch(this.toUpdate);
      else if (this.toUpdate is String && int.tryParse(this.toUpdate) != null)
        timePart =
            DateTime.fromMillisecondsSinceEpoch(int.parse(this.toUpdate));
      else
        timePart = DateTime(1970);
    }

    timePart = DateTime(
        date.year,
        date.month,
        date.day,
        timePart.hour,
        timePart.minute,
        timePart.second,
        timePart.millisecond,
        timePart.microsecond);

    this.toUpdate = date.millisecondsSinceEpoch;
  }

  void setTimePart(TimeOfDay time) {
    DateTime date;
    if (this.toUpdate == null)
      date = DateTime(1970);
    else
      date = DateTime.fromMillisecondsSinceEpoch(this.toUpdate);

    date = DateTime(
        date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);

    this.toUpdate = date.millisecondsSinceEpoch;
  }
}
