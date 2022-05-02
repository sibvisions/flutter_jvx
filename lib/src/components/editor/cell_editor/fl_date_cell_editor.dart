import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:intl/intl.dart';

import '../../../model/component/editor/cell_editor/fl_date_cell_editor_model.dart';
import '../../../model/component/label/fl_label_model.dart';
import '../../../model/data/column_definition.dart';
import '../../label/fl_label_widget.dart';
import 'i_cell_editor.dart';

class FlDateCellEditor extends ICellEditor<FlDateCellEditorModel, dynamic> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  dynamic _value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlDateCellEditor({
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
  }) : super(
          model: FlDateCellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;
  }

  @override
  FlLabelWidget getWidget(BuildContext pContext) {
    FlLabelModel widgetModel = FlLabelModel();

    if (_value != null) {
      widgetModel.text = DateFormat(model.dateFormat).format(DateTime.fromMillisecondsSinceEpoch(_value!));
    }

    return FlLabelWidget(
      model: widgetModel,
      forceBorder: true,
      onPress: () => openDatePicker(pContext),
    );
  }

  void openDatePicker(BuildContext pContext) {
    FocusManager.instance.primaryFocus?.unfocus();

    // TODO locale
    if (model.isDateEditor && model.isTimeEditor) {
      _openDateAndTimeEditors(pContext);
    } else if (model.isDateEditor) {
      _openDateEditor(pContext);
    } else if (model.isTimeEditor) {
      _openTimeEditor(pContext);
    }
  }

  void _openDateAndTimeEditors(BuildContext pContext) {
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

  void _openDateEditor(BuildContext pContext) {
    uiService
        .openDialog(
            pDialogWidget: DatePickerDialog(
              initialDate: DateTime.fromMillisecondsSinceEpoch(_value ?? 0),
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

  void _openTimeEditor(BuildContext pContext) {
    uiService
        .openDialog(
            pDialogWidget: TimePickerDialog(
              initialTime: TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(_value ?? 0)),
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
  FlLabelModel getWidgetModel() => FlLabelModel();

  @override
  void dispose() {
    // Do nothing
  }

  @override
  String getValue() {
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

  void _setDateTime(DateTime dateTime) {
    _value = dateTime.millisecondsSinceEpoch;
  }
}
