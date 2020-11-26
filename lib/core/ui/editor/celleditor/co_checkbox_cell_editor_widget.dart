import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../ui/layout/i_alignment_constants.dart';
import 'co_cell_editor_widget.dart';
import 'models/checkbox_cell_editor_model.dart';

class CoCheckboxCellEditorWidget extends CoCellEditorWidget {
  final CheckBoxCellEditorModel cellEditorModel;

  CoCheckboxCellEditorWidget({
    CellEditor changedCellEditor,
    this.cellEditorModel,
    Key key,
  }) : super(
          changedCellEditor: changedCellEditor,
          cellEditorModel: cellEditorModel,
          key: key,
        );

  @override
  State<StatefulWidget> createState() => CoCheckboxCellEditorWidgetState();
}

class CoCheckboxCellEditorWidgetState
    extends CoCellEditorWidgetState<CoCheckboxCellEditorWidget> {
  void valueChanged(dynamic value) {
    this.value = widget.cellEditorModel.boolToValue(value);
    this.onValueChanged(this.value, indexInTable);
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);
    return Container(
      child: Row(
        mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
            widget.cellEditorModel.horizontalAlignment),
        children: <Widget>[
          Checkbox(
            value: widget.cellEditorModel.valueToBool(this.value),
            onChanged: (bool change) =>
                (widget.cellEditorModel.editable != null &&
                        widget.cellEditorModel.editable)
                    ? valueChanged(change)
                    : null,
            tristate: false,
          ),
          widget.cellEditorModel.text != null
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          widget.cellEditorModel.text != null
              ? Text(widget.cellEditorModel.text)
              : Container(),
        ],
      ),
    );
  }
}
