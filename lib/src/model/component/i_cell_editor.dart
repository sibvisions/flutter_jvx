import 'package:flutter/cupertino.dart';
import 'package:flutter_client/src/model/data/cell_editor_model.dart';
import '../api/api_object_property.dart';
import 'dummy/fl_dummy_cell_editor.dart';
import 'editor/fl_text_cell_editor.dart';
import '../../service/api/shared/fl_component_classname.dart';

abstract class ICellEditor<T extends ICellEditorModel> {
  late T model;

  Widget get widget;

  static ICellEditor getCellEditor(Map<String, dynamic> cellEditorJson) {
    String cellEditorClassName = cellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(cellEditorJson);
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        continue alsoDefault;
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        continue alsoDefault;
      case FlCellEditorClassname.IMAGE_VIEWER:
        continue alsoDefault;
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        continue alsoDefault;
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        continue alsoDefault;
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        continue alsoDefault;

      alsoDefault:
      default:
        return FlDummyCellEditor({});
    }
  }
}
