/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

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
abstract class ICellEditor<
    WidgetModelType extends FlComponentModel,
    WidgetType extends FlStatelessWidget<WidgetModelType>,
    CellEditorModelType extends ICellEditorModel,
    ReturnValueType> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the component this cell editor is part of.
  String? name;

  /// The cell editor model
  CellEditorModelType model;

  Function(ReturnValueType) onValueChange;

  Function(ReturnValueType) onEndEditing;

  Function(bool) onFocusChanged;

  ColumnDefinition? columnDefinition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor({
    required this.model,
    required Map<String, dynamic> pCellEditorJson,
    required this.onValueChange,
    required this.onEndEditing,
    required this.onFocusChanged,
    this.name,
    this.columnDefinition,
  }) {
    model.applyFromJson(pCellEditorJson);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void dispose();

  ReturnValueType? getValue();

  void setValue(dynamic pValue);

  void setColumnDefinition(ColumnDefinition? pColumnDefinition) => columnDefinition = pColumnDefinition;

  ColumnDefinition? getColumnDefinition() => columnDefinition;

  /// Returns the widget representing the cell editor.
  WidgetType createWidget(Map<String, dynamic>? pJson, bool pInTable);

  /// Returns the model of the widget representing the cell editor.
  WidgetModelType createWidgetModel();

  /// If the cell editor can be inside a table.
  bool get canBeInTable => false;

  String formatValue(dynamic pValue);

  double getContentPadding(Map<String, dynamic>? pJson, bool pInTable);

  double? getEditorWidth(Map<String, dynamic>? pJson, bool pInTable);

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
    required Function(bool) onFocusChanged,
    CellEditorRecalculateSizeCallback? pRecalculateSizeCallback,
  }) {
    String? cellEditorClassName = pCellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
        );
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        return FlCheckBoxCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
        );
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        return FlNumberCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
        );
      case FlCellEditorClassname.IMAGE_VIEWER:
        return FlImageCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        return FlChoiceCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        return FlDateCellEditor(
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        return FlLinkedCellEditor(
          name: pName,
          columnDefinition: columnDefinition,
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
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
