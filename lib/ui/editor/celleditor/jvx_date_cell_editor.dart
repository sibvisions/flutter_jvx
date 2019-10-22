import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';

class JVxDateCellEditor extends JVxCellEditor {
  String dateFormat;

  JVxDateCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    dateFormat =
        changedCellEditor.getProperty<String>(CellEditorProperty.DATE_FORMAT);
  }

  void onDateValueChanged(dynamic value) {
    super.onValueChanged(value);
  }

  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return FlatButton(
      child: Text((this.value != null)
          ? DateFormat(this.dateFormat)
              .format(DateTime.fromMillisecondsSinceEpoch(this.value))
          : ''),
      onPressed: () => showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(2050),
        initialDate: (this.value != null)
            ? DateTime.fromMillisecondsSinceEpoch(this.value)
            : DateTime.now().subtract(Duration(seconds: 1)),
      ).then((date) {
        if (date != null) {
          this.value = date.toString();
          this.onDateValueChanged(date.millisecondsSinceEpoch);
        }
      }),
    );
  }
}
