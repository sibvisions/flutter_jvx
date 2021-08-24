import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'co_cell_editor_widget.dart';
import 'models/date_cell_editor_model.dart';

class CoDateCellEditorWidget extends CoCellEditorWidget {
  CoDateCellEditorWidget({required DateCellEditorModel cellEditorModel})
      : super(cellEditorModel: cellEditorModel);

  @override
  CoCellEditorWidgetState<CoDateCellEditorWidget> createState() =>
      CoDateCellEditorWidgetState();
}

class CoDateCellEditorWidgetState
    extends CoCellEditorWidgetState<CoDateCellEditorWidget> {
  void onDateValueChanged(dynamic value) {
    (widget.cellEditorModel as DateCellEditorModel).toUpdate = null;
    if (super.onValueChanged != null)
      super.onValueChanged!(
          context, value, widget.cellEditorModel.indexInTable);
  }

  _getTimePopUp(BuildContext context) {
    TextUtils.unfocusCurrentTextfield(context);

    return showTimePicker(
            context: context,
            initialTime: (widget.cellEditorModel.cellEditorValue != null &&
                    widget.cellEditorModel.cellEditorValue is int)
                ? TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(
                    widget.cellEditorModel.cellEditorValue))
                : TimeOfDay.fromDateTime(
                    DateTime.now().subtract(Duration(seconds: 1))))
        .then((time) {
      if (time != null) {
        (widget.cellEditorModel as DateCellEditorModel).setTimePart(time);
        this.onDateValueChanged(
            (widget.cellEditorModel as DateCellEditorModel).toUpdate);
      }
    });
  }

  _getDateTimePopUp(BuildContext context) {
    TextUtils.unfocusCurrentTextfield(context);

    return showDatePicker(
      context: context,
      locale:
          Locale(widget.cellEditorModel.appState.language?.language ?? 'en'),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      initialDate: (widget.cellEditorModel.cellEditorValue != null &&
              widget.cellEditorModel.cellEditorValue is int)
          ? DateTime.fromMillisecondsSinceEpoch(
              widget.cellEditorModel.cellEditorValue)
          : DateTime.now().subtract(Duration(seconds: 1)),
    ).then((date) {
      DateCellEditorModel cellEditorModel =
          widget.cellEditorModel as DateCellEditorModel;

      if (date != null &&
          cellEditorModel.isTimeFormat &&
          cellEditorModel.isTimeEditor) {
        cellEditorModel.setDatePart(date);
        SchedulerBinding.instance!.addPostFrameCallback((_) async {
          await showTimePicker(
                  context: context,
                  initialTime:
                      (widget.cellEditorModel.cellEditorValue != null &&
                              widget.cellEditorModel.cellEditorValue is int)
                          ? TimeOfDay.fromDateTime(
                              DateTime.fromMillisecondsSinceEpoch(
                                  widget.cellEditorModel.cellEditorValue))
                          : TimeOfDay.fromDateTime(
                              DateTime.now().subtract(Duration(seconds: 1))))
              .then((time) {
            if (time != null) {
              cellEditorModel.setTimePart(time);
              this.onDateValueChanged(cellEditorModel.toUpdate);
            }
          });
        });
      } else {
        if (date != null) {
          cellEditorModel.setDatePart(date);
          this.onDateValueChanged(cellEditorModel.toUpdate);
        }
      }
    });
  }

  Border _getBorder() {
    if (widget.cellEditorModel.borderVisible &&
        widget.cellEditorModel.editable) {
      return Border.all(color: Theme.of(context).primaryColor);
    } else {
      return Border.all(color: Colors.grey);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.cellEditorModel.isTableView) {
      return Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: widget.cellEditorModel.backgroundColor != null
              ? widget.cellEditorModel.backgroundColor
              : Colors.white.withOpacity(widget.cellEditorModel.appState
                      .applicationStyle?.controlsOpacity ??
                  1.0),
          borderRadius: widget.cellEditorModel.appState.applicationStyle != null
              ? BorderRadius.circular(widget.cellEditorModel.appState
                      .applicationStyle?.cornerRadiusEditors ??
                  5)
              : null,
          border: _getBorder(),
        ),
        child: ElevatedButton(
            style: ButtonStyle(
                elevation: MaterialStateProperty.all(0.0),
                backgroundColor: MaterialStateProperty.all(
                    widget.cellEditorModel.editable
                        ? Colors.white
                        : Colors.grey.shade200),
                padding: MaterialStateProperty.all(
                    EdgeInsets.fromLTRB(10, 10, 10, 10))),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: kIsWeb ? const EdgeInsets.only(left: 8) : EdgeInsets.zero,
                      child: Text(
                        (widget.cellEditorModel.cellEditorValue != null &&
                                (widget.cellEditorModel.cellEditorValue is int ||
                                    int.tryParse(widget.cellEditorModel.cellEditorValue) !=
                                        null))
                            ? DateFormat((widget.cellEditorModel
                                        as DateCellEditorModel)
                                    .dateFormat)
                                .format(DateTime.fromMillisecondsSinceEpoch(widget
                                        .cellEditorModel
                                        .cellEditorValue is String
                                    ? int.parse(
                                        widget.cellEditorModel.cellEditorValue)
                                    : widget.cellEditorModel.cellEditorValue))
                            : widget.cellEditorModel.placeholder ?? '',
                        style: (widget.cellEditorModel.cellEditorValue !=
                                    null &&
                                widget.cellEditorModel.cellEditorValue is int)
                            ? TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: widget.cellEditorModel.foregroundColor ==
                                        null
                                    ? Colors.black
                                    : widget.cellEditorModel.foregroundColor)
                            : TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.calendarAlt,
                      color: Colors.grey[600],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    (widget.cellEditorModel as DateCellEditorModel)
                                    .cellEditorValue !=
                                null &&
                            (widget.cellEditorModel as DateCellEditorModel)
                                    .cellEditorValue !=
                                ''
                        ? GestureDetector(
                            child: Icon(
                              Icons.clear,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              (widget.cellEditorModel as DateCellEditorModel)
                                  .toUpdate = null;
                              this.onDateValueChanged((widget.cellEditorModel
                                      as DateCellEditorModel)
                                  .toUpdate);
                            },
                          )
                        : Container()
                  ],
                )
              ],
            ),
            onPressed: widget.cellEditorModel.editable
                ? () => ((widget.cellEditorModel as DateCellEditorModel)
                            .isTimeFormat &&
                        !(widget.cellEditorModel as DateCellEditorModel)
                            .isDateFormat)
                    ? _getTimePopUp(context)
                    : _getDateTimePopUp(context)
                : null),
      );
    } else {
      // Pref Editor Mode
      // 1 = Single Click
      // 0 = Double Click

      if (widget.cellEditorModel.editable &&
          (widget.cellEditorModel.preferredEditorMode != null &&
              widget.cellEditorModel.preferredEditorMode == 0)) {
        return GestureDetector(
          onTap: () {
            DateCellEditorModel cellEditorModel =
                widget.cellEditorModel as DateCellEditorModel;

            if ((cellEditorModel.isTimeFormat &&
                    cellEditorModel.isTimeEditor) &&
                (!cellEditorModel.isDateFormat &&
                    !cellEditorModel.isDateEditor)) {
              _getTimePopUp(context);
            } else {
              _getDateTimePopUp(context);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    (widget.cellEditorModel.cellEditorValue != null &&
                            (widget.cellEditorModel.cellEditorValue is int ||
                                int.tryParse(widget
                                        .cellEditorModel.cellEditorValue) !=
                                    null))
                        ? DateFormat(
                                (widget.cellEditorModel as DateCellEditorModel)
                                    .dateFormat)
                            .format(DateTime.fromMillisecondsSinceEpoch(widget
                                    .cellEditorModel.cellEditorValue is String
                                ? int.parse(
                                    widget.cellEditorModel.cellEditorValue)
                                : widget.cellEditorModel.cellEditorValue))
                        : widget.cellEditorModel.placeholder ?? '',
                    style: (widget.cellEditorModel.cellEditorValue != null &&
                            widget.cellEditorModel.cellEditorValue is int)
                        ? TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color:
                                widget.cellEditorModel.foregroundColor == null
                                    ? Colors.black
                                    : widget.cellEditorModel.foregroundColor)
                        : TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.calendarAlt,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    (widget.cellEditorModel as DateCellEditorModel)
                                    .cellEditorValue !=
                                null &&
                            (widget.cellEditorModel as DateCellEditorModel)
                                    .cellEditorValue !=
                                ''
                        ? GestureDetector(
                            child: Icon(
                              Icons.clear,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              (widget.cellEditorModel as DateCellEditorModel)
                                  .toUpdate = null;
                              this.onDateValueChanged((widget.cellEditorModel
                                      as DateCellEditorModel)
                                  .toUpdate);
                            },
                          )
                        : Container()
                  ],
                ),
              )
            ],
          ),
        );
      } else {
        if (widget.cellEditorModel.cellEditorValue is String &&
            int.tryParse(widget.cellEditorModel.cellEditorValue) != null) {
          widget.cellEditorModel.cellEditorValue =
              int.parse(widget.cellEditorModel.cellEditorValue);
        }

        String text = (widget.cellEditorModel.cellEditorValue != null &&
                widget.cellEditorModel.cellEditorValue is int)
            ? DateFormat(
                    (widget.cellEditorModel as DateCellEditorModel).dateFormat)
                .format(DateTime.fromMillisecondsSinceEpoch(
                    widget.cellEditorModel.cellEditorValue))
            : '';

        return Align(alignment: Alignment.centerLeft, child: Text(text));
      }
    }
  }
}
