import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/cell_editor.dart';

import 'referenced_cell_editor_model.dart';

class MultiLineCellEditorModel extends ReferencedCellEditorModel {
  List<ListTile> items = <ListTile>[];
  String? selectedValue;

  MultiLineCellEditorModel({required CellEditor cellEditor})
      : super(cellEditor: cellEditor);
}
