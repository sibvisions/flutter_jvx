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
  dynamic selectedValue = true;
  dynamic deselectedValue = false;
  String text;

  @override
  void initState() {
    super.initState();

    selectedValue = widget.changedCellEditor
        .getProperty<dynamic>(CellEditorProperty.SELECTED_VALUE, selectedValue);
    deselectedValue = widget.changedCellEditor.getProperty<dynamic>(
        CellEditorProperty.DESELECTED_VALUE, deselectedValue);
    text = widget.changedCellEditor
        .getProperty<String>(CellEditorProperty.TEXT, text);
  }

  void valueChanged(dynamic value) {
    this.value = widget.cellEditorModel.boolToValue(value);
    this.onValueChanged(this.value, indexInTable);
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);
    return Container(
      // decoration: BoxDecoration(
      //     color: background != null ? background : Colors.transparent,
      //     borderRadius: BorderRadius.circular(5),
      //     border:
      //         borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: Row(
        mainAxisAlignment:
            IAlignmentConstants.getMainAxisAlignment(this.horizontalAlignment),
        children: <Widget>[
          Checkbox(
            value: widget.cellEditorModel.valueToBool(this.value),
            onChanged: (bool change) => (this.editable != null && this.editable)
                ? valueChanged(change)
                : null,
            tristate: false,
          ),
          text != null
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          text != null ? Text(text) : Container(),
        ],
      ),
    );
  }
}
