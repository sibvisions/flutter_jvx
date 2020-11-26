import 'package:flutter/material.dart';

import '../../../../models/api/editor/cell_editor.dart';
import 'referenced_cell_editor_model.dart';

class MultiLineCellEditorModel extends ReferencedCellEditorModel {
  List<ListTile> items = <ListTile>[];
  String selectedValue;

  MultiLineCellEditorModel(CellEditor cellEditor) : super(cellEditor);
}
