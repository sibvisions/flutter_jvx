import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../../service/api/shared/fl_component_classname.dart';
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
abstract class ICellEditor<WidgetModelType extends FlComponentModel,
    WidgetType extends FlStatelessWidget<WidgetModelType>, CellEditorModelType extends ICellEditorModel, ReturnValues> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the component this cell editor is part of.
  String? name;

  /// The cell editor model
  CellEditorModelType model;

  Function(ReturnValues) onValueChange;

  Function(ReturnValues) onEndEditing;

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

  ReturnValues? getValue();

  void setValue(dynamic pValue);

  void setColumnDefinition(ColumnDefinition? pColumnDefinition) => columnDefinition = pColumnDefinition;

  ColumnDefinition? getColumnDefinition() => columnDefinition;

  /// Returns the widget representing the cell editor.
  WidgetType createWidget(Map<String, dynamic>? pJson, bool pInTable);

  /// Returns the model of the widget representing the cell editor.
  WidgetModelType createWidgetModel();

  /// If the cell editor catches the focus.
  bool isInTable() => false;

  String formatValue(Object pValue);

  double get additionalTablePadding;

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
  }) {
    String cellEditorClassName = pCellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        return FlCheckBoxCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        return FlNumberCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        );
      case FlCellEditorClassname.IMAGE_VIEWER:
        return FlImageCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        return FlChoiceCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        return FlDateCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        return FlLinkedCellEditor(
          name: pName,
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );

      default:
        return FlDummyCellEditor();
    }
  }

  static void applyEditorJson(FlComponentModel pModel, Map<String, dynamic>? pJson) {
    if (pJson != null) {
      pModel.applyFromJson(pJson);
      pModel.applyCellEditorOverrides(pJson);
    }
  }
}
