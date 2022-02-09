import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/dummy/fl_dummy_model.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/service/api/shared/fl_component_classname.dart';

abstract class FlCellEditor {
  static FlComponentModel getCellEditorModel(Map<String, dynamic> pJson) {
    Map<String, dynamic> cellEditorJson = pJson[ApiObjectProperty.cellEditor];
    String cellEditorClassName = cellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        continue alsoDefault;
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
        return FlDummyModel();
    }
  }
}
