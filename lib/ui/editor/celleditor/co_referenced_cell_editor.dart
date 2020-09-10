import 'package:flutter/widgets.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import '../../../model/cell_editor.dart';
import '../../../model/column_view.dart';
import '../../../model/link_reference.dart';
import '../../screen/so_component_data.dart';
import 'co_cell_editor.dart';

class CoReferencedCellEditor extends CoCellEditor {
  LinkReference linkReference;
  ColumnView columnView;
  SoComponentData _data;

  CoReferencedCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    linkReference = changedCellEditor.linkReference;
    columnView = changedCellEditor.columnView;
    if (linkReference?.dataProvider == null)
      linkReference?.dataProvider = linkReference?.referencedDataBook;
    if (dataProvider == null) dataProvider = linkReference?.dataProvider;
  }

  factory CoReferencedCellEditor.withCompContext(
      ComponentContext componentContext) {
    return CoReferencedCellEditor(
        componentContext.cellEditor, componentContext.context);
  }

  SoComponentData get data => _data;
  set data(SoComponentData data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);
  }

  void onServerDataChanged() {}
}
