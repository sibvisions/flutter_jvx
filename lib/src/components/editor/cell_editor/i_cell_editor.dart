import 'package:flutter/cupertino.dart';
import 'package:flutter_client/src/components/editor/cell_editor/date/fl_date_cell_editor.dart';
import 'package:flutter_client/src/components/editor/cell_editor/fl_number_cell_editor.dart';
import 'package:flutter_client/src/components/editor/cell_editor/linked/fl_linked_cell_editor.dart';

import '../../../model/api/api_object_property.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../service/api/shared/fl_component_classname.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import 'fl_check_box_cell_editor.dart';
import 'fl_choice_cell_editor.dart';
import 'fl_dummy_cell_editor.dart';
import 'fl_image_cell_editor.dart';
import 'fl_text_cell_editor.dart';

/// A cell editor wraps around a editing component and handles all relevant events and value changes.
abstract class ICellEditor<T extends ICellEditorModel, C> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The id of the component this cell editor is part of.
  String id;

  /// The cell editor model
  T model;

  Function(C) onValueChange;

  Function(C) onEndEditing;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor({
    required this.id,
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

  void setValue(dynamic pValue);

  void setColumnDefinition(ColumnDefinition? pColumnDefinition);

  ColumnDefinition? getColumnDefinition();

  /// Returns the widget representing the cell editor.
  FlStatelessWidget getWidget(BuildContext pContext);

  /// Returns the model of the widget representing the cell editor.
  FlComponentModel getWidgetModel();

  bool isActionCellEditor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns a [ICellEditor] based on the cell editor class name
  static ICellEditor getCellEditor({
    required String pId,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    VoidCallback? pRecalculateSize,
  }) {
    String cellEditorClassName = pCellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(
          id: pId,
          pCellEditorJson: pCellEditorJson,
          onChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        return FlCheckBoxCellEditor(
          id: pId,
          pCellEditorJson: pCellEditorJson,
          onChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        return FlNumberCellEditor(
          id: pId,
          pCellEditorJson: pCellEditorJson,
          onChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.IMAGE_VIEWER:
        return FlImageCellEditor(
            id: pId,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            imageLoadingCallback: pRecalculateSize);
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        return FlChoiceCellEditor(
            id: pId,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            imageLoadingCallback: pRecalculateSize);
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        return FlDateCellEditor(
            id: pId,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            imageLoadingCallback: pRecalculateSize);
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        return FlLinkedCellEditor(
            id: pId,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            imageLoadingCallback: pRecalculateSize);

      default:
        return FlDummyCellEditor(id: pId, pCellEditorJson: pCellEditorJson);
    }
  }
}
