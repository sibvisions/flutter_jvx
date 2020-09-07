import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../../../utils/text_utils.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import 'co_cell_editor.dart';
import '../../../utils/globals.dart' as globals;
import '../../../utils/uidata.dart';

class CoDateCellEditor extends CoCellEditor {
  String dateFormat;
  dynamic toUpdate;

  get isTimeFormat {
    return dateFormat.contains("H") || dateFormat.contains("m");
  }

  get isDateFormat {
    return dateFormat.contains("d") ||
        dateFormat.contains("M") ||
        dateFormat.contains("y");
  }

  @override
  get preferredSize {
    String text = DateFormat(this.dateFormat)
        .format(DateTime.parse("2020-12-31 22:22:22Z"));

    if (text.isEmpty) text = TextUtils.averageCharactersDateField;

    double width =
        TextUtils.getTextWidth(text, Theme.of(context).textTheme.bodyText1)
            .toDouble();
    return Size(width + 16, 50);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  CoDateCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    preferredEditorMode = changedCellEditor
        .getProperty<int>(CellEditorProperty.PREFERRED_EDITOR_MODE);
    dateFormat =
        changedCellEditor.getProperty<String>(CellEditorProperty.DATE_FORMAT);
  }

  factory CoDateCellEditor.withCompContext(ComponentContext componentContext) {
    return CoDateCellEditor(
        componentContext.cellEditor, componentContext.context);
  }

  void onDateValueChanged(dynamic value) {
    this.toUpdate = null;
    super.onValueChanged(value, indexInTable);
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

  _getDateTimePopUp() {
    TextUtils.unfocusCurrentTextfield(context);

    return showDatePicker(
      context: context,
      locale: Locale(globals.language),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      initialDate: (this.value != null && this.value is int)
          ? DateTime.fromMillisecondsSinceEpoch(this.value)
          : DateTime.now().subtract(Duration(seconds: 1)),
    ).then((date) {
      if (date != null && isTimeFormat) {
        this.setDatePart(date);
        return showTimePicker(
                context: context,
                initialTime: (this.value != null && this.value is int)
                    ? TimeOfDay.fromDateTime(
                        DateTime.fromMillisecondsSinceEpoch(this.value))
                    : TimeOfDay.fromDateTime(
                        DateTime.now().subtract(Duration(seconds: 1))))
            .then((time) {
          if (time != null) {
            this.setTimePart(time);
            this.onDateValueChanged(this.toUpdate);
          }
        });
      } else {
        if (date != null) {
          this.setDatePart(date);
          this.onDateValueChanged(this.toUpdate);
        }
      }
    });
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

    // this.isTableView = false;

    if (!this.isTableView) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
            color: background != null
                ? background
                : Colors.white.withOpacity(
                    globals.applicationStyle?.controlsOpacity ?? 1.0),
            borderRadius: BorderRadius.circular(
                globals.applicationStyle.cornerRadiusEditors),
            border: borderVisible
                ? (this.editable
                    ? Border.all(color: UIData.ui_kit_color_2)
                    : Border.all(color: Colors.grey))
                : null),
        child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      (this.value != null &&
                              (this.value is int ||
                                  int.tryParse(this.value) != null))
                          ? DateFormat(this.dateFormat).format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  this.value is String
                                      ? int.parse(this.value)
                                      : this.value))
                          : (placeholderVisible && placeholder != null
                              ? placeholder
                              : ""),
                      style: (this.value != null && this.value is int)
                          ? TextStyle(
                              fontSize: 16,
                              color: this.foreground == null
                                  ? Colors.grey[700]
                                  : this.foreground)
                          : TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                SizedBox(
                  width: 58,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        FontAwesomeIcons.calendarAlt,
                        color: Colors.grey[600],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.clear,
                          size: 24,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          this.toUpdate = null;
                          this.onDateValueChanged(this.toUpdate);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
            onPressed: () => _getDateTimePopUp()),
      );
    } else {
      // Pref Editor Mode
      // 1 = Single Click
      // 0 = Double Click

      if (this.editable && this.preferredEditorMode == 0) {
        return GestureDetector(
          onTap: () => _getDateTimePopUp(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    (this.value != null &&
                            (this.value is int ||
                                int.tryParse(this.value) != null))
                        ? DateFormat(this.dateFormat).format(
                            DateTime.fromMillisecondsSinceEpoch(
                                this.value is String
                                    ? int.parse(this.value)
                                    : this.value))
                        : (placeholderVisible && placeholder != null
                            ? placeholder
                            : ""),
                    style: (this.value != null && this.value is int)
                        ? TextStyle(
                            fontSize: 16,
                            color: this.foreground == null
                                ? Colors.grey[700]
                                : this.foreground)
                        : TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              SizedBox(
                width: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      FontAwesomeIcons.calendarAlt,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      onTap: () {
                        this.toUpdate = null;
                        this.onDateValueChanged(this.toUpdate);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        );
      } else {
        if (this.value is String && int.tryParse(this.value) != null) {
          this.value = int.parse(this.value);
        }

        String text = (this.value != null && this.value is int)
            ? DateFormat(this.dateFormat)
                .format(DateTime.fromMillisecondsSinceEpoch(this.value))
            : '';

        return Text(text);
      }
    }
  }
}
