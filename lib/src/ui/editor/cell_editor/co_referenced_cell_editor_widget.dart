import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_cell_editor_widget.dart';

import 'models/referenced_cell_editor_model.dart';

class CoReferencedCellEditorWidget extends CoCellEditorWidget {
  final ReferencedCellEditorModel cellEditorModel;

  CoReferencedCellEditorWidget({required this.cellEditorModel})
      : super(cellEditorModel: cellEditorModel);

  @override
  CoCellEditorWidgetState<CoCellEditorWidget> createState() =>
      CoCellEditorWidgetState();
}

class CoReferencedCellEditorWidgetState
    extends CoCellEditorWidgetState<CoReferencedCellEditorWidget> {}
