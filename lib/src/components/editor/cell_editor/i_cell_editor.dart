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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/response/record_format.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../../service/api/shared/fl_component_classname.dart';
import 'date/fl_date_cell_editor.dart';
import 'fl_check_box_cell_editor.dart';
import 'fl_choice_cell_editor.dart';
import 'fl_dummy_cell_editor.dart';
import 'fl_image_cell_editor.dart';
import 'fl_number_cell_editor.dart';
import 'fl_text_cell_editor.dart';
import 'linked/fl_linked_cell_editor.dart';

typedef RecalculateCallback = Function([bool pRecalculate]);
typedef CellEditorFocusChecker = bool Function(IFocusableCellEditor cellEditor);

/// A cell editor wraps around a editing component and handles all relevant events and value changes.
abstract class ICellEditor<WidgetModelType extends FlComponentModel, CellEditorModelType extends ICellEditorModel,
    ReturnValueType> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The json of this cell editor.
  Map<String, dynamic> cellEditorJson;

  /// The name of the component this cell editor is part of.
  String? name;

  /// The cell editor model
  CellEditorModelType model;

  Function(ReturnValueType?) onValueChange;

  Function(ReturnValueType?) onEndEditing;

  ColumnDefinition? columnDefinition;

  /// If the cell editor can be inside a table.
  bool get allowedInTable => false;

  /// If the cell can be edited inside a table.
  bool get allowedTableEdit => false;

  /// If the cell can be deleted inside a table.
  bool get tableDeleteIcon => allowedTableEdit;

  /// The icon of the table cell.
  IconData? get tableEditIcon => null;

  bool isInTable;

  /// The cell format of this cell editor
  CellFormat? cellFormat;

  String columnName;

  String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor({
    required this.model,
    required this.cellEditorJson,
    required this.onValueChange,
    required this.onEndEditing,
    required this.dataProvider,
    required this.columnName,
    this.isInTable = false,
    this.name,
    this.columnDefinition,
  }) {
    model.applyFromJson(cellEditorJson);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void dispose();

  Future<ReturnValueType?> getValue();

  void setValue(dynamic pValue);

  void setColumnDefinition(ColumnDefinition? pColumnDefinition) => columnDefinition = pColumnDefinition;

  ColumnDefinition? getColumnDefinition() => columnDefinition;

  /// Returns the widget representing the cell editor.
  Widget createWidget(Map<String, dynamic>? pJson);

  /// Returns the model of the widget representing the cell editor.
  WidgetModelType createWidgetModel();

  String formatValue(dynamic pValue);

  double getContentPadding(Map<String, dynamic>? pJson) {
    return 0.0;
  }

  double? getEditorWidth(Map<String, dynamic>? pJson);

  double? getEditorHeight(Map<String, dynamic>? pJson);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Static methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns a [ICellEditor] based on the cell editor class name
  static ICellEditor getCellEditor({
    required String pName,
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    required Function(bool) onFocusChanged,
    required bool isInTable,
    RecalculateCallback? pRecalculateCallback,
    required String dataProvider,
    required String columnName,
    CellEditorFocusChecker? focusChecker
  }) {
    String? cellEditorClassName = pCellEditorJson[ApiObjectProperty.className];

    switch (cellEditorClassName) {
      case FlCellEditorClassname.TEXT_CELL_EDITOR:
        return FlTextCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          columnName: columnName,
          dataProvider: dataProvider,
        );
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        return FlCheckBoxCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          columnName: columnName,
          dataProvider: dataProvider,
        );
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        return FlNumberCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          columnName: columnName,
          dataProvider: dataProvider,
        );
      case FlCellEditorClassname.IMAGE_VIEWER:
        return FlImageCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          isInTable: isInTable,
          recalculateSizeCallback: pRecalculateCallback,
          columnName: columnName,
          dataProvider: dataProvider,
        );
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        return FlChoiceCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          isInTable: isInTable,
          recalculateSizeCallback: pRecalculateCallback,
          columnName: columnName,
          dataProvider: dataProvider
        );
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        return FlDateCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          columnName: columnName,
          dataProvider: dataProvider,
          focusChecker: focusChecker
        );
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        return FlLinkedCellEditor(
          name: pName,
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          columnName: columnName,
          dataProvider: dataProvider,
          focusChecker: focusChecker
        );

      default:
        return FlDummyCellEditor();
    }
  }

  void applyEditorJson(FlComponentModel pModel, Map<String, dynamic>? pJson) {
    pModel.applyFromJson(pJson ?? {});
    pModel.applyFromJson(cellEditorJson);
    pModel.applyCellEditorOverrides(pJson ?? {});
    if (cellFormat != null) {
      pModel.applyCellFormat(cellFormat!);
    }
  }
}

/// A cell editor that can be focused.
abstract class IFocusableCellEditor<
    WidgetModelType extends FlComponentModel,
    CellEditorModelType extends ICellEditorModel,
    ReturnValueType> extends ICellEditor<WidgetModelType, CellEditorModelType, ReturnValueType> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The focus node of this cell editor.
  FocusNode focusNode = FocusNode();

  /// The callback function that is called when the focus of this cell editor changes.
  Function(bool)? onFocusChanged;

  /// Whether the first focus request should be ignored
  CellEditorFocusChecker? focusChecker;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  IFocusableCellEditor({
    required super.model,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.columnName,
    required super.dataProvider,
    super.isInTable = false,
    super.name,
    super.columnDefinition,
    this.onFocusChanged,
    this.focusChecker
  }) {
    focusNode.addListener(() {
      focusChanged(focusNode.hasFocus);
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if the onFocusChanged callback is fired on "focusChanged".
  bool firesFocusCallback() => true;

  /// Is called when the focus changes.
  @nonVirtual
  void focusChanged(bool pHasFocus) {
    //If there's a local focus checker, don't handle focus if it's not expected
    if (focusChecker != null) {
      if (!focusChecker!(this)) {
        focusNode.unfocus();
        return;
      }
    }

    handleFocusChanged(pHasFocus);
  }

  void handleFocusChanged(bool pHasFocus) {
    if (onFocusChanged != null && firesFocusCallback()) {
        onFocusChanged!(pHasFocus);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  dispose() {
    focusNode.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Focuses this cell editor.
  void focus() {
    focusNode.requestFocus();
  }

  /// Unfocuses this cell editor.
  void unfocus() {
    focusNode.unfocus();
  }

  /// Sets the focus node of this cell editor.
  void setFocusNode(FocusNode pFocusNode) {
    focusNode.dispose();
    focusNode = pFocusNode;
  }

  /// Returns the focus node of this cell editor.
  FocusNode getFocusNode() {
    return focusNode;
  }

  /// Adds a listener to the focus node of this cell editor.
  void addFocusNodeListener(Function() listener) {
    focusNode.addListener(listener);
  }

  /// Removes a listener from the focus node of this cell editor.
  void removeFocusNodeListener(Function() listener) {
    focusNode.removeListener(listener);
  }
}
