import 'package:flutter/cupertino.dart';
import '../api/api_object_property.dart';
import 'dummy/fl_dummy_cell_editor.dart';
import 'editor/fl_text_cell_editor.dart';
import '../../service/api/shared/fl_component_classname.dart';

abstract class ICellEditor {
  Widget get widget;

  static ICellEditor getCellEditor(Map<String, dynamic> pJson) {
    Map<String, dynamic> cellEditorJson = pJson[ApiObjectProperty.cellEditor];
    String cellEditorClassName = cellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(pJson);
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
        return FlDummyCellEditor(pJson);
    }
  }
}
