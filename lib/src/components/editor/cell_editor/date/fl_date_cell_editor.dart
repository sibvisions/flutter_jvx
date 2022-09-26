import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/component/editor/cell_editor/date/fl_date_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../i_cell_editor.dart';
import 'fl_date_editor_widget.dart';

class FlDateCellEditor extends ICellEditor<FlDateEditorModel, FlDateEditorWidget, FlDateCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  IUiService uiService;

  dynamic _value;

  TextEditingController textController = TextEditingController();

  FocusNode focusNode = FocusNode();

  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlDateCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    this.recalculateSizeCallback,
    required this.uiService,
  }) : super(
          model: FlDateCellEditorModel(),
        ) {
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
          openDatePicker();
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
        pValue = DateFormat(model.dateFormat).format(DateTime.fromMillisecondsSinceEpoch(pValue));
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
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlDateEditorModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    return FlDateEditorWidget(
      model: widgetModel,
      textController: textController,
      focusNode: focusNode,
      endEditing: onEndEditing,
      valueChanged: onValueChange,
      inTable: pInTable,
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

  @override
  bool isInTable() => true;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void openDatePicker() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (model.isDateEditor && model.isTimeEditor) {
      _openDateAndTimeEditors();
    } else if (model.isDateEditor) {
      _openDateEditor();
    } else if (model.isTimeEditor) {
      _openTimeEditor();
    }
  }

  void _openDateAndTimeEditors() {
    bool cancelled = false;
    dynamic originalValue = _value;

    uiService
        .openDialog(
            pBuilder: (_) => DatePickerDialog(
                  initialDate: DateTime.fromMillisecondsSinceEpoch(_value ?? 0),
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
        return;
      }
      uiService
          .openDialog(
              pBuilder: (_) => TimePickerDialog(
                    initialTime: TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(_value ?? 0)),
                  ),
              pIsDismissible: true)
          .then((value) {
        if (value == null) {
          cancelled = true;
        } else {
          _setTimePart(value ?? const TimeOfDay(hour: 0, minute: 0));
        }
      }).then((_) {
        if (cancelled) {
          _value = originalValue;
        } else {
          onEndEditing(_value);
        }
      });
    });
  }

  void _openDateEditor() {
    uiService
        .openDialog(
            pBuilder: (_) => DatePickerDialog(
                  initialDate: DateTime.fromMillisecondsSinceEpoch(_value),
                  firstDate: DateTime.fromMillisecondsSinceEpoch(_value).subtract(const Duration(days: 36525)),
                  lastDate: DateTime.fromMillisecondsSinceEpoch(_value).add(const Duration(days: 36525)),
                ),
            pIsDismissible: true)
        .then((value) {
      if (value != null) {
        _setDatePart(value ?? DateTime.fromMillisecondsSinceEpoch(_value));
        onEndEditing(_value);
      }
    });
  }

  void _openTimeEditor() {
    uiService
        .openDialog(
            pBuilder: (_) => TimePickerDialog(
                  initialTime: TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(_value)),
                ),
            pIsDismissible: true)
        .then((value) {
      if (value != null) {
        _setTimePart(value ?? const TimeOfDay(hour: 0, minute: 0));
        onEndEditing(_value);
      }
    });
  }

  void _setDatePart(DateTime date) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(_value ?? 0);

    _value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
      time.millisecond,
      time.microsecond,
    ).millisecondsSinceEpoch;
  }

  void _setTimePart(TimeOfDay timePart) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(_value ?? 0);

    _value = DateTime(
      date.year,
      date.month,
      date.day,
      model.isHourEditor ? timePart.hour : 0,
      model.isMinuteEditor ? timePart.minute : 0,
      0,
      0,
      0,
    ).millisecondsSinceEpoch;
  }

  @override
  String formatValue(pValue) {
    if (pValue is int) {
      return DateFormat(model.dateFormat).format(DateTime.fromMillisecondsSinceEpoch(pValue));
    }
    return pValue.toString();
  }

  @override
  double get additionalTablePadding {
    return createWidget(null, true).extraWidthPaddings();
  }
}
