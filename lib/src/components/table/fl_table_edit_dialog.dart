import 'dart:math';

import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../editor/cell_editor/i_cell_editor.dart';

class FlTableEditDialog extends StatefulWidget {
  final int rowIndex;

  final ValueNotifier<Map<String, dynamic>?> newValueNotifier;

  final List<ColumnDefinition> columnDefinitions;

  final Map<String, dynamic> values;

  final TableValueChangedCallback onEndEditing;

  final FlTableModel model;

  const FlTableEditDialog({
    super.key,
    required this.rowIndex,
    required this.columnDefinitions,
    required this.values,
    required this.onEndEditing,
    required this.newValueNotifier,
    required this.model,
  });

  @override
  State<FlTableEditDialog> createState() => _FlTableEditDialogState();
}

class _FlTableEditDialogState extends State<FlTableEditDialog> {
  List<ICellEditor> cellEditors = [];

  @override
  void initState() {
    super.initState();

    widget.newValueNotifier.addListener(receiveNewValues);

    widget.columnDefinitions.forEach((colDef) {
      var cellEditor = ICellEditor.getCellEditor(
        pName: widget.model.name,
        pCellEditorJson: colDef.cellEditorJson,
        columnDefinition: colDef,
        onChange: (_) {},
        onEndEditing: (value) => widget.onEndEditing(value, widget.rowIndex, colDef.name),
        onFocusChanged: (_) {},
        isInTable: false,
      );
      cellEditor.setValue(widget.values[colDef.name]);
      cellEditors.add(cellEditor);
    });
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
    if (widget.columnDefinitions.length == 1) {
      dialogLabel = FlutterUI.translate("Edit");
    } else {
      dialogLabel = FlutterUI.translate("Edit row");
    }

    List<Widget> editorWidgets = [];
    if (widget.columnDefinitions.length == 1) {
      ICellEditor cellEditor = cellEditors[0];
      Widget editorWidget = cellEditor.createWidget(null);

      if (cellEditor is FlChoiceCellEditor || cellEditor is FlImageCellEditor) {
        editorWidget = SizedBox.square(dimension: cellEditor.getEditorWidth(null), child: editorWidget);
      }
      editorWidgets.add(editorWidget);
    } else {
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogLabel,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 4),
              ...editorWidgets,
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: Text(
                    FlutterUI.translate("Ok"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.newValueNotifier.removeListener(receiveNewValues);
    cellEditors.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  // void onCellEditorEndEditing(String pColumn, dynamic pValue) {
  //   // Linked cell editors sometimes return a map of values, already mapped to their corresponding columns.
  //   if (pValue is Map) {
  //     pValue.forEach((key, value) {
  //       widget.values[key] = value;
  //     });
  //   } else {
  //     widget.values[pColumn] = pValue;
  //   }
  // }

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
}
