/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import '../../../../service/config/config_controller.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/parse_util.dart';
import '../i_cell_editor.dart';
import 'fl_date_editor_widget.dart';

class FlDateCellEditor extends ICellEditor<FlDateEditorModel, FlDateEditorWidget, FlDateCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  dynamic _value;

  TextEditingController textController = TextEditingController();

  bool isOpen = false;

  FocusNode focusNode = FocusNode(skipTraversal: true);

  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  Function(Function)? onAction;

  @override
  bool get allowedInTable => false;

  @override
  bool get allowedTableEdit => model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK;

  @override
  bool get tableDeleteIcon => true;

  @override
  IconData? get tableEditIcon => FontAwesomeIcons.calendar;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlDateCellEditor({
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.onFocusChanged,
    super.isInTable,
    this.recalculateSizeCallback,
    this.onAction,
  }) : super(
          model: FlDateCellEditorModel(),
        ) {
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
          if (onAction != null) {
            onAction!(_openDatePicker);
          } else {
            _openDatePicker();
          }
          focusNode.unfocus();
        }
      },
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;

    if (pValue == null) {
      textController.clear();
    } else {
      if (pValue is! String) {
        pValue = formatValue(pValue);
      }

      textController.value = textController.value.copyWith(
        text: pValue,
        selection: TextSelection.collapsed(offset: pValue.characters.length),
        composing: null,
      );
    }

    recalculateSizeCallback?.call(false);
  }

  @override
  createWidget(Map<String, dynamic>? pJson) {
    FlDateEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    return FlDateEditorWidget(
      model: widgetModel,
      textController: textController,
      focusNode: focusNode,
      endEditing: onEndEditing,
      valueChanged: onValueChange,
      inTable: isInTable,
      hideClearIcon: allowedTableEdit && isInTable,
    );
  }

  @override
  createWidgetModel() => FlDateEditorModel();

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
  }

  @override
  dynamic getValue() {
    return _value;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  tz.Location _getLocation() {
    return tz.getLocation(model.timeZoneCode ?? ConfigController().getTimezone());
  }

  DateTime _createDateTime(dynamic value) {
    return tz.TZDateTime.fromMillisecondsSinceEpoch(_getLocation(), value);
  }

  void _openDatePicker() {
    if (!isOpen) {
      onFocusChanged(true);
      isOpen = true;

      DateTime initialDate;
      TimeOfDay initialTime;
      if (_value != null) {
        initialDate = _createDateTime(_value);
        initialTime = TimeOfDay.fromDateTime(initialDate);
      } else {
        initialDate = DateTime.now();
        initialTime = TimeOfDay.now();
      }

      if (model.isDateEditor && model.isTimeEditor) {
        _openDateAndTimeEditors(initialDate, initialTime);
      } else if (model.isDateEditor) {
        _openDateEditor(initialDate);
      } else if (model.isTimeEditor) {
        _openTimeEditor(initialTime);
      }
    }
  }

  void _openDateAndTimeEditors(DateTime pInitialDate, TimeOfDay pInitialTime) {
    bool cancelled = false;
    dynamic originalValue = _value;

    IUiService()
        .openDialog(
            pBuilder: (_) => DatePickerDialog(
                  initialDate: pInitialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                ),
            pIsDismissible: true)
        .then((value) {
      if (value == null) {
        cancelled = true;
      } else {
        _setDatePart(value);
      }
    }).then((_) {
      if (cancelled) {
        _value = originalValue;
        isOpen = false;
        return;
      }
      IUiService()
          .openDialog(
              pBuilder: (_) => TimePickerDialog(
                    initialTime: pInitialTime,
                  ),
              pIsDismissible: true)
          .then((value) {
        if (value == null) {
          cancelled = true;
        } else {
          _setTimePart(value);
        }
      }).then((_) {
        if (cancelled) {
          _value = originalValue;
        } else {
          onEndEditing(_value);
        }
        isOpen = false;
      });
    });
  }

  void _openDateEditor(DateTime pInitialDate) {
    IUiService()
        .openDialog(
            pBuilder: (_) => DatePickerDialog(
                  initialDate: pInitialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                ),
            pIsDismissible: true)
        .then((value) {
      if (value != null) {
        _setDatePart(value);
        onEndEditing(_value);
      }
      isOpen = false;
    });
  }

  void _openTimeEditor(TimeOfDay pInitialTime) {
    IUiService()
        .openDialog(
            pBuilder: (_) => TimePickerDialog(
                  initialTime: pInitialTime,
                ),
            pIsDismissible: true)
        .then((value) {
      if (value != null) {
        _setTimePart(value);
        onEndEditing(_value);
      }
      isOpen = false;
    });
  }

  void _setDatePart(DateTime date) {
    TimeOfDay timePart = TimeOfDay.fromDateTime(_createDateTime(_value ?? 0));

    _setDateTime(date, timePart);
  }

  void _setTimePart(TimeOfDay timePart) {
    DateTime date = _createDateTime(_value ?? 0);

    _setDateTime(date, timePart);
  }

  void _setDateTime(DateTime pDate, TimeOfDay pTimePart) {
    _value = tz.TZDateTime(
      _getLocation(),
      pDate.year,
      pDate.month,
      pDate.day,
      model.isHourEditor ? pTimePart.hour : 0,
      model.isMinuteEditor ? pTimePart.minute : 0,
      0,
      0,
      0,
    ).millisecondsSinceEpoch;
  }

  @override
  String formatValue(dynamic pValue) {
    if (pValue is int) {
      return DateFormat(
        model.dateFormat,
        model.locale ?? ConfigController().getLanguage(),
      ).format(_createDateTime(pValue));
    }
    return pValue?.toString() ?? "";
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson) {
    return createWidget(pJson).extraWidthPaddings();
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson) {
    FlDateEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    double colWidth = ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle());

    if (isInTable) {
      return colWidth * widgetModel.columns / 2;
    }
    return colWidth * widgetModel.columns;
  }
}
