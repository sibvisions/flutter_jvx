import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../util/parse_util.dart';
import '../../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../i_cell_editor.dart';
import 'fl_date_editor_widget.dart';

class FlDateCellEditor extends ICellEditor<FlDateEditorModel, FlDateEditorWidget, FlDateCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  dynamic _value;

  TextEditingController textController = TextEditingController();

  FocusNode focusNode = FocusNode(skipTraversal: true);

  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlDateCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.onFocusChanged,
    this.recalculateSizeCallback,
  }) : super(
          model: FlDateCellEditorModel(),
        ) {
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
          onFocusChanged(true);
          openDatePicker();
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
      hideClearIcon: model.preferredEditorMode == ICellEditorModel.DOUBLE_CLICK && pInTable,
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
  bool get canBeInTable => true;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void openDatePicker() {
    DateTime initialDate;
    TimeOfDay initialTime;
    if (_value != null) {
      initialDate = DateTime.fromMillisecondsSinceEpoch(_value);
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
    });
  }

  void _setDatePart(DateTime date) {
    TimeOfDay timePart = TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(_value ?? 0));

    _setDateTime(date, timePart);
  }

  void _setTimePart(TimeOfDay timePart) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(_value ?? 0);

    _setDateTime(date, timePart);
  }

  void _setDateTime(DateTime pDate, TimeOfDay pTimePart) {
    _value = DateTime(
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
      return DateFormat(model.dateFormat).format(DateTime.fromMillisecondsSinceEpoch(pValue));
    }
    return pValue?.toString() ?? "";
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson, bool pInTable) {
    return createWidget(pJson, pInTable).extraWidthPaddings();
  }

  @override
  double getEditorSize(Map<String, dynamic>? pJson, bool pInTable) {
    FlDateEditorModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    double colWidth = ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle());

    if (pInTable) {
      return colWidth * widgetModel.columns / 2;
    }
    return colWidth * widgetModel.columns;
  }
}
