import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import 'cell_editor_model.dart';

class CheckBoxCellEditorModel extends CellEditorModel {
  dynamic selectedValue = true;
  dynamic deselectedValue = false;
  String text;

  CheckBoxCellEditorModel(CellEditor currentCellEditor)
      : super(currentCellEditor) {
    selectedValue = currentCellEditor.getProperty<dynamic>(
        CellEditorProperty.SELECTED_VALUE, selectedValue);
    deselectedValue = currentCellEditor.getProperty<dynamic>(
        CellEditorProperty.DESELECTED_VALUE, deselectedValue);
    text = currentCellEditor.getProperty<String>(CellEditorProperty.TEXT, text);
  }

  dynamic boolToValue(bool value) {
    if (value) return selectedValue;
    return deselectedValue;
  }

  bool valueToBool(dynamic value) {
    if (value != null && value == selectedValue) return true;
    return false;
  }
}
