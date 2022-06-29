import 'package:flutter/cupertino.dart';

import '../../../model/api/api_object_property.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../service/api/shared/fl_component_classname.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import 'date/fl_date_cell_editor.dart';
import 'fl_check_box_cell_editor.dart';
import 'fl_choice_cell_editor.dart';
import 'fl_dummy_cell_editor.dart';
import 'fl_image_cell_editor.dart';
import 'fl_number_cell_editor.dart';
import 'fl_text_cell_editor.dart';
import 'linked/fl_linked_cell_editor.dart';

typedef CellEditorRecalculateSizeCallback = Function([bool pRecalculate]);

/// A cell editor wraps around a editing component and handles all relevant events and value changes.
abstract class ICellEditor<T extends ICellEditorModel, C> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the component this cell editor is part of.
  String? name;

  /// The cell editor model
  T model;

  Function(C) onValueChange;

  Function(C) onEndEditing;

  ColumnDefinition? columnDefinition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor({
    required this.model,
    required Map<String, dynamic> pCellEditorJson,
    required this.onValueChange,
    required this.onEndEditing,
    this.name,
    this.columnDefinition,
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
  FlStatelessWidget createWidget(BuildContext pContext);

  /// Returns the widget for the table.
  FlStatelessWidget? createTableWidget(BuildContext pContext);

  /// Returns the model of the widget representing the cell editor.
  FlComponentModel createWidgetModel();

  bool isActionCellEditor();

  String formatValue(Object pValue);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns a [ICellEditor] based on the cell editor class name
  static ICellEditor getCellEditor({
    required String pName,
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    CellEditorRecalculateSizeCallback? pRecalculateSizeCallback,
    required IUiService pUiService,
  }) {
    String cellEditorClassName = pCellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        return FlCheckBoxCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        return FlNumberCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.IMAGE_VIEWER:
        return FlImageCellEditor(
            columnDefinition: columnDefinition,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            recalculateSizeCallback: pRecalculateSizeCallback);
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        return FlChoiceCellEditor(
            columnDefinition: columnDefinition,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            recalculateSizeCallback: pRecalculateSizeCallback);
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        return FlDateCellEditor(
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            recalculateSizeCallback: pRecalculateSizeCallback,
            uiService: pUiService);
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        return FlLinkedCellEditor(
            name: pName,
            columnDefinition: columnDefinition,
            pCellEditorJson: pCellEditorJson,
            onChange: onChange,
            onEndEditing: onEndEditing,
            recalculateSizeCallback: pRecalculateSizeCallback,
            uiService: pUiService);

      default:
        return FlDummyCellEditor();
    }
  }
}
