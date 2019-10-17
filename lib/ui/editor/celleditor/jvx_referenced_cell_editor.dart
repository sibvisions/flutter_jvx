import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/link_reference.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'jvx_cell_editor.dart';

class JVxReferencedCellEditor extends JVxCellEditor {
  LinkReference linkReference;
  ColumnView columnView;
  ComponentData _data;

  JVxReferencedCellEditor(CellEditor changedCellEditor, BuildContext context) : super(changedCellEditor, context) {
      linkReference = changedCellEditor.linkReference;
      columnView = changedCellEditor.columnView;
  }

  ComponentData get data => _data;
  set data(ComponentData data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);
  }

  void onServerDataChanged() {

  }
}