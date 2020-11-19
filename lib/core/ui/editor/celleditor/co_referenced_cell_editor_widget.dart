import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/referenced_cell_editor_model.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/column_view.dart';
import '../../../models/api/editor/link_reference.dart';
import '../../screen/so_component_data.dart';
import 'cell_editor_model.dart';
import 'co_cell_editor_widget.dart';

class CoReferencedCellEditorWidget extends CoCellEditorWidget {
  final ReferencedCellEditorModel cellEditorModel;

  CoReferencedCellEditorWidget({
    CellEditor changedCellEditor,
    this.cellEditorModel,
  }) : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() =>
      CoReferencedCellEditorWidgetState<CoReferencedCellEditorWidget>();
}

class CoReferencedCellEditorWidgetState<T extends StatefulWidget>
    extends CoCellEditorWidgetState<T> {
  @override
  void initState() {
    super.initState();

    (widget as CoReferencedCellEditorWidget)
        .cellEditorModel
        .referencedData
        ?.registerDataChanged(onServerDataChanged);
  }

  void onServerDataChanged() {
    this.setState(() {});
  }

  @override
  void dispose() {
    (widget as CoReferencedCellEditorWidget)
        .cellEditorModel
        .referencedData
        ?.unregisterDataChanged(onServerDataChanged);
    super.dispose();
  }
}
