import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/cell_editor.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/cell_editor_properties.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';
import 'package:intl/intl.dart';

import 'cell_editor_model.dart';

class DateCellEditorModel extends CellEditorModel {
  String? dateFormat;
  dynamic? toUpdate;
  bool isDateEditor = false;
  bool isSecondEditor = false;
  bool isHourEditor = false;
  bool isMinuteEditor = false;
  bool isAmPmEditor = false;
  bool isTimeEditor = false;

  @override
  get preferredSize {
    return _getPreferredSize();
  }

  @override
  get minimumSize {
    return Size(110, 50);
  }

  @override
  get tablePreferredSize {
    return _getPreferredSize(cellEditorValue);
  }

  @override
  get tableMinimumSize {
    return this.tablePreferredSize;
  }

  get isTimeFormat {
    return this.dateFormat!.contains("H") || this.dateFormat!.contains("m");
  }

  get isDateFormat {
    return this.dateFormat!.contains("d") ||
        this.dateFormat!.contains("M") ||
        this.dateFormat!.contains("y");
  }

  Size _getPreferredSize([dynamic value]) {
    String text = DateFormat(this.dateFormat)
        .format(DateTime.parse("2020-12-31 22:22:22Z"));

    if (value != null && int.tryParse(value) != null)
      text = DateFormat(this.dateFormat)
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(value)));

    if (text.isEmpty) text = TextUtils.averageCharactersDateField;

    double width =
        TextUtils.getTextWidth(text, fontStyle, textScaleFactor).toDouble();
    return Size(width + (isTableView ? 65 : 110), 50);
  }

  DateCellEditorModel({required CellEditor cellEditor})
      : super(cellEditor: cellEditor) {
    preferredEditorMode = this.cellEditor.getProperty<int>(
        CellEditorProperty.PREFERRED_EDITOR_MODE, preferredEditorMode);

    dateFormat = this
        .cellEditor
        .getProperty<String>(CellEditorProperty.DATE_FORMAT, dateFormat ?? '');

    if (dateFormat?.contains('Y') ?? false)
      dateFormat = dateFormat?.replaceAll('Y', 'y');
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
