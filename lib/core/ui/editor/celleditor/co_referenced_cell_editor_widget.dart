import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import 'co_cell_editor_widget.dart';
import 'models/referenced_cell_editor_model.dart';

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
