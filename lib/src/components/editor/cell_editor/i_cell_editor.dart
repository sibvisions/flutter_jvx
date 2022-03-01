import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/model/data/cell_editor_model.dart';
import '../../../model/api/api_object_property.dart';
import '../../../model/component/dummy/fl_dummy_cell_editor.dart';
import 'fl_text_cell_editor.dart';
import '../../../service/api/shared/fl_component_classname.dart';

/// A cell editor wraps around a editing component and handles all relevant events and value changes.
abstract class ICellEditor<T extends ICellEditorModel, C> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The cell editor model
  T model;

  Function(C) onValueChange;

  Function(C) onEndEditing;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor({
    required this.model,
    required Map<String, dynamic> pCellEditorJson,
    required this.onValueChange,
    required this.onEndEditing,
  }) {
    model.applyFromJson(pCellEditorJson);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void dispose();

  C? getValue();

  void setValue(C? pValue);

  /// Returns the widget representing the cell editor.
  FlStatelessWidget getWidget();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns a [ICellEditor] based on the cell editor class name
  static ICellEditor getCellEditor({
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
  }) {
    String cellEditorClassName = pCellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(pCellEditorJson: pCellEditorJson, onChange: onChange, onEndEditing: onEndEditing);
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
        return FlDummyCellEditor(pCellEditorJson: pCellEditorJson);
    }
  }
}
