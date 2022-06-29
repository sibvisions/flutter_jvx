import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:intl/intl.dart';

import '../../../../model/component/editor/cell_editor/date/fl_date_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import '../../../../model/component/label/fl_label_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../i_cell_editor.dart';
import 'fl_date_editor_widget.dart';

class FlDateCellEditor extends ICellEditor<FlDateCellEditorModel, dynamic> {
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
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.recalculateSizeCallback,
    required this.uiService,
  }) : super(
          columnDefinition: columnDefinition,
          model: FlDateCellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
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
  FlDateEditorWidget createWidget(BuildContext pContext, [bool pInTable = false]) {
    FlDateEditorModel widgetModel = FlDateEditorModel();

    return FlDateEditorWidget(
      model: widgetModel,
      textController: textController,
      focusNode: focusNode,
      onPress: () => openDatePicker(),
      inTable: pInTable,
    );
  }

  void openDatePicker() {
    FocusManager.instance.primaryFocus?.unfocus();

    // TODO locale
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
            pDialogWidget: DatePickerDialog(
              initialDate: DateTime.fromMillisecondsSinceEpoch(_value ?? 0),
              firstDate: DateTime(1970),
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
              pDialogWidget: TimePickerDialog(
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
            pDialogWidget: DatePickerDialog(
              initialDate: DateTime.fromMillisecondsSinceEpoch(_value),
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            ),
            pIsDismissible: true)
        .then((value) {
      if (value != null) {
        _setDatePart(value ?? DateTime(1970));
        onEndEditing(_value);
      }
    });
  }

  void _openTimeEditor() {
    uiService
        .openDialog(
            pDialogWidget: TimePickerDialog(
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

  @override
  FlLabelModel createWidgetModel() => FlLabelModel();

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
  bool isActionCellEditor() {
    return true;
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    // do nothing
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return null;
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
  FlStatelessWidget? createTableWidget(BuildContext pContext) {
    return createWidget(pContext, true);
  }
}
