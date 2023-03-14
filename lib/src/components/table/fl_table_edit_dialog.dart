import 'dart:math';

import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/api/restore_data_command.dart';
import '../../model/component/fl_component_model.dart';
import '../editor/cell_editor/i_cell_editor.dart';

/// A dialog that allows editing columns in a table.
class FlTableEditDialog extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The index of the row to edit.
  final int rowIndex;

  /// If the row got updated while the dialog was open, this will be called.
  final ValueNotifier<Map<String, dynamic>?> newValueNotifier;

  /// The column definitions of the columns to edit.
  final List<ColumnDefinition> columnDefinitions;

  /// The values of the row to edit.
  final Map<String, dynamic> values;

  /// Called when the user is done editing a cell. Will only happen if more than one cell is edited.
  final TableValueChangedCallback onEndEditing;

  /// The model of the table.
  final FlTableModel model;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableEditDialog({
    super.key,
    required this.rowIndex,
    required this.columnDefinitions,
    required this.values,
    required this.onEndEditing,
    required this.newValueNotifier,
    required this.model,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<FlTableEditDialog> createState() => _FlTableEditDialogState();
}

class _FlTableEditDialogState extends State<FlTableEditDialog> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The cell editors of the columns to edit.
  List<ICellEditor> cellEditors = [];

  /// If the table edits a singular column, the dialog will switch to local editing, without immediatly sending the value to the server.
  /// Moreover the cancel button will only cancel the local changes, instead of resetting the whole row.
  bool get isSingleColumnEdit => widget.columnDefinitions.length == 1;

  /// The local value if the dialog only edits one column.
  dynamic localValue;

  /// If the dialog was dismissed by either button.
  bool dismissedByButton = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    widget.newValueNotifier.addListener(receiveNewValues);

    widget.columnDefinitions.forEach((colDef) {
      var cellEditor = ICellEditor.getCellEditor(
        pName: widget.model.name,
        columnName: colDef.name,
        dataProvider: widget.model.dataProvider,
        pCellEditorJson: colDef.cellEditorJson,
        columnDefinition: colDef,
        onChange: (value) {
          localValue = value;
        },
        onEndEditing: (value) {
          localValue = value;
          if (!isSingleColumnEdit) {
            widget.onEndEditing(value, widget.rowIndex, colDef.name);
          }
        },
        onFocusChanged: (_) {},
        isInTable: false,
      );
      cellEditor.setValue(widget.values[colDef.name]);
      cellEditors.add(cellEditor);
    });

    for (ICellEditor cellEditor in cellEditors) {
      if (cellEditor is IFocusableCellEditor) {
        cellEditor.focus();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    EdgeInsets paddingInsets;

    paddingInsets = EdgeInsets.fromLTRB(
      screenSize.width / 16,
      screenSize.height / 16,
      screenSize.width / 16,
      screenSize.height / 16,
    );

    String dialogLabel;
    List<Widget> editorWidgets = [];

    if (isSingleColumnEdit) {
      dialogLabel = widget.columnDefinitions.first.label;

      ICellEditor cellEditor = cellEditors[0];
      Widget editorWidget = cellEditor.createWidget(null);

      if (cellEditor is FlChoiceCellEditor || cellEditor is FlImageCellEditor) {
        editorWidget = SizedBox.square(dimension: cellEditor.getEditorWidth(null), child: editorWidget);
      } else if (cellEditor is FlTextCellEditor && editorWidget is FlTextAreaWidget) {
        editorWidget = SizedBox(
          height: 100,
          child: editorWidget,
        );
      }
      editorWidgets.add(editorWidget);
    } else {
      dialogLabel = FlutterUI.translate("Edit record");

      double labelColumnWidth = 0.0;

      for (int i = 0; i < widget.columnDefinitions.length; i++) {
        double labelWidth = ParseUtil.getTextWidth(
          text: widget.columnDefinitions[i].label,
          style: widget.model.createTextStyle(),
        );

        labelColumnWidth = max(labelColumnWidth, labelWidth);
      }

      labelColumnWidth += 5;

      for (int i = 0; i < widget.columnDefinitions.length; i++) {
        ICellEditor cellEditor = cellEditors[i];
        Widget editorWidget = cellEditor.createWidget(null);

        if (cellEditor is FlChoiceCellEditor || cellEditor is FlImageCellEditor) {
          editorWidget = Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(dimension: cellEditor.getEditorWidth(null), child: editorWidget),
          );
        } else if (cellEditor is FlTextCellEditor && editorWidget is FlTextAreaWidget) {
          editorWidget = SizedBox(
            height: 100,
            child: editorWidget,
          );
        }

        editorWidget = Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: labelColumnWidth,
                child: Text(
                  widget.columnDefinitions[i].label,
                  style: widget.model.createTextStyle(),
                ),
              ),
              Expanded(child: editorWidget),
            ],
          ),
        );

        editorWidgets.add(editorWidget);
      }
    }

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
              dialogLabel,
              style: Theme.of(context).dialogTheme.titleTextStyle,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: editorWidgets,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _handleCancel,
                      child: Text(
                        FlutterUI.translate("Cancel"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                TextButton(
                  onPressed: _handleOk,
                  child: Text(
                    FlutterUI.translate("Ok"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!dismissedByButton) {
      _handleCancel(true);
    }
    widget.newValueNotifier.removeListener(receiveNewValues);
    cellEditors.forEach((cellEditor) {
      cellEditor.dispose();
    });
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void receiveNewValues() {
    Map<String, dynamic>? newValues = widget.newValueNotifier.value;

    setState(() {
      if (newValues != null) {
        for (String columnName in newValues.keys) {
          int colIndex = widget.columnDefinitions.indexWhere((element) => element.name == columnName);
          if (colIndex >= 0) {
            cellEditors[colIndex].setValue(newValues[columnName]);
          }
        }
      }
    });
  }

  void _handleOk() {
    dismissedByButton = true;
    if (isSingleColumnEdit) {
      widget.onEndEditing(localValue, widget.rowIndex, widget.columnDefinitions.first.name);
    }

    Navigator.of(context).pop();
  }

  void _handleCancel([bool fromDispose = false]) {
    dismissedByButton = true;
    if (!isSingleColumnEdit) {
      IUiService().sendCommand(RestoreDataCommand(
        dataProvider: widget.model.dataProvider,
        reason: "Pressed cancel in table edit dialog",
      ));
    }
    if (!fromDispose) {
      Navigator.of(context).pop();
    }
  }
}
