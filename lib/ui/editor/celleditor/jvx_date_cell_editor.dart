import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text((this.value != null && this.value is int)
              ? DateFormat(this.dateFormat)
                  .format(DateTime.fromMillisecondsSinceEpoch(this.value))
              : ''),
          Icon(FontAwesomeIcons.calendarAlt, color: Colors.grey[600],)
        ],
      ),
      onPressed: () => showDatePicker(
        context: context,
        locale: Locale(globals.language),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050),
        initialDate: (this.value != null && this.value is int)
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
