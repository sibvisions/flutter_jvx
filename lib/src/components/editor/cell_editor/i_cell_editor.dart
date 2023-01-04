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

import 'package:flutter/material.dart';

import '../../../flutter_ui.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/response/dal_fetch_response.dart';
import '../../../service/api/shared/api_object_property.dart';
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
abstract class ICellEditor<
    WidgetModelType extends FlComponentModel,
    WidgetType extends FlStatelessWidget<WidgetModelType>,
    CellEditorModelType extends ICellEditorModel,
    ReturnValueType> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Object _OK_PRESSED = Object();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The json of this celleditor.
  Map<String, dynamic> cellEditorJson;

  /// The name of the component this cell editor is part of.
  String? name;

  /// The cell editor model
  CellEditorModelType model;

  Function(ReturnValueType?) onValueChange;

  Function(ReturnValueType?) onEndEditing;

  Function(bool) onFocusChanged;

  ColumnDefinition? columnDefinition;

  /// If the cell editor can be inside a table.
  bool get allowedInTable => false;

  /// If the cell editor can be edited inside a table.
  bool get allowedTableEdit => false;

  bool isInTable;

  /// The cellformat of this cellEditor
  CellFormat? cellFormat;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor({
    required this.model,
    required this.cellEditorJson,
    required this.onValueChange,
    required this.onEndEditing,
    required this.onFocusChanged,
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

  ReturnValueType? getValue();

  void setValue(dynamic pValue);

  void setColumnDefinition(ColumnDefinition? pColumnDefinition) => columnDefinition = pColumnDefinition;

  ColumnDefinition? getColumnDefinition() => columnDefinition;

  /// Returns the widget representing the cell editor.
  WidgetType createWidget(Map<String, dynamic>? pJson);

  /// Returns the model of the widget representing the cell editor.
  WidgetModelType createWidgetModel();

  String formatValue(dynamic pValue);

  double getContentPadding(Map<String, dynamic>? pJson);

  double? getEditorWidth(Map<String, dynamic>? pJson);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void tableEdit(Map<String, dynamic>? pJson, String pColumn) {
    dynamic cellEditorValue = getValue();
    ICellEditor cellEditor = ICellEditor.getCellEditor(
      pName: name ?? "",
      columnDefinition: columnDefinition,
      onFocusChanged: (_) {},
      onChange: (_) {},
      onEndEditing: (_) {},
      isInTable: false,
      pCellEditorJson: cellEditorJson,
    );

    cellEditor.onEndEditing = (value) {
      cellEditorValue = value;
      if (cellEditorValue is Map<String, dynamic>) {
        cellEditor.setValue(cellEditorValue[pColumn]);
      } else {
        cellEditor.setValue(value);
      }
    };

    cellEditor.setValue(getValue());

    IUiService()
        .openDialog(pBuilder: (context) => _buildPopupEditor(context, pJson, cellEditor), pIsDismissible: true)
        .then((pressed) {
      if (cellEditorValue != _OK_PRESSED && pressed == _OK_PRESSED && cellEditorValue != getValue()) {
        onEndEditing(cellEditorValue);
      }

      cellEditor.dispose();
    });
  }

  Dialog _buildPopupEditor(BuildContext context, Map<String, dynamic>? pJson, ICellEditor pCellEditor) {
    Size screenSize = MediaQuery.of(context).size;

    EdgeInsets paddingInsets;

    paddingInsets = EdgeInsets.fromLTRB(
      screenSize.width / 16,
      screenSize.height / 16,
      screenSize.width / 16,
      screenSize.height / 16,
    );

    List<Widget> listBottomButtons = [];

    Widget leftSideButton = const SizedBox();

    if (columnDefinition?.nullable == true) {
      InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Builder(
          builder: (context) => Text(
            style: TextStyle(
              shadows: [
                Shadow(
                  offset: const Offset(0, -2),
                  color: DefaultTextStyle.of(context).style.color!,
                )
              ],
              color: Colors.transparent,
              decoration: TextDecoration.underline,
              decorationColor: DefaultTextStyle.of(context).style.color,
              decorationThickness: 1,
            ),
            FlutterUI.translate("No value"),
          ),
        ),
      );
    }

    listBottomButtons.add(
      Flexible(
        child: Align(
          alignment: Alignment.centerLeft,
          child: leftSideButton,
        ),
      ),
    );

    listBottomButtons.add(
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          child: Text(
            FlutterUI.translate("Cancel"),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    listBottomButtons.add(const SizedBox(width: 10));

    listBottomButtons.add(
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          child: Text(
            FlutterUI.translate("Ok"),
          ),
          onPressed: () {
            Navigator.of(context).pop(_OK_PRESSED);
          },
        ),
      ),
    );

    return Dialog(
      insetPadding: paddingInsets,
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterUI.translate("Edit ${columnDefinition?.label}"),
              style: Theme.of(context).dialogTheme.titleTextStyle,
            ),
            const SizedBox(height: 8),
            pCellEditor.createWidget(pJson),
            const SizedBox(height: 8),
            Row(
              children: listBottomButtons,
            ),
          ],
        ),
      ),
    );
  }

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
    Function(Function action)? onAction,
    required bool isInTable,
    CellEditorRecalculateSizeCallback? pRecalculateSizeCallback,
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
        );
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        return FlCheckBoxCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
        );
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        return FlNumberCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
        );
      case FlCellEditorClassname.IMAGE_VIEWER:
        return FlImageCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        return FlChoiceCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          recalculateSizeCallback: pRecalculateSizeCallback,
        );
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        return FlDateCellEditor(
          columnDefinition: columnDefinition,
          cellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
          onFocusChanged: onFocusChanged,
          isInTable: isInTable,
          recalculateSizeCallback: pRecalculateSizeCallback,
          onAction: onAction,
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
          recalculateSizeCallback: pRecalculateSizeCallback,
          onAction: onAction,
        );

      default:
        return FlDummyCellEditor();
    }
  }

  void applyEditorJson(FlComponentModel pModel, Map<String, dynamic>? pJson) {
    if (pJson != null) {
      pModel.applyFromJson(pJson);
      pModel.applyCellEditorOverrides(pJson);
      if (cellFormat != null) {
        pModel.applyCellFormat(cellFormat!);
      }
    }
  }
}
