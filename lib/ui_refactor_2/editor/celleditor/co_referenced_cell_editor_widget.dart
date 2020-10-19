import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui/editor/celleditor/co_referenced_cell_editor.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/co_editor_widget.dart';

import '../../../model/cell_editor.dart';
import '../../../model/column_view.dart';
import '../../../model/link_reference.dart';
import '../../screen/so_component_data.dart';
import 'cell_editor_model.dart';
import 'co_cell_editor_widget.dart';

class CoReferencedCellEditorWidget extends CoCellEditorWidget {
  CoReferencedCellEditorWidget({
    CellEditor changedCellEditor,
    CellEditorModel cellEditorModel,
  }) : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() =>
      CoReferencedCellEditorWidgetState<CoReferencedCellEditorWidget>();
}

class CoReferencedCellEditorWidgetState<T extends StatefulWidget>
    extends CoCellEditorWidgetState<T> {
  LinkReference linkReference;
  ColumnView columnView;
  SoComponentData _data;

  SoComponentData get data => _data;
  set data(SoComponentData data) {
    _data?.unregisterDataChanged(onServerDataChanged);
    _data = data;
    _data?.registerDataChanged(onServerDataChanged);
  }

  void onServerDataChanged() {
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
    this.data = (widget as CoReferencedCellEditorWidget).cellEditorModel.data;

    linkReference = (widget as CoReferencedCellEditorWidget)
        .changedCellEditor
        .linkReference;
    columnView =
        (widget as CoReferencedCellEditorWidget).changedCellEditor.columnView;
    if (linkReference?.dataProvider == null)
      linkReference?.dataProvider = linkReference?.referencedDataBook;
    if (dataProvider == null) dataProvider = linkReference?.dataProvider;
  }
}
