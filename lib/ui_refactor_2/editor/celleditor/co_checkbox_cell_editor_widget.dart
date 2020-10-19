import 'package:flutter/material.dart';

import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import '../../../ui/layout/i_alignment_constants.dart';
import 'cell_editor_model.dart';
import 'co_cell_editor_widget.dart';

class CoCheckboxCellEditorWidget extends CoCellEditorWidget {
  CoCheckboxCellEditorWidget({
    CellEditor changedCellEditor,
    CellEditorModel cellEditorModel,
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
    this.value = boolToValue(value);
    this.onValueChanged(this.value, indexInTable);
  }

  dynamic boolToValue(bool value) {
    if (value) return selectedValue;
    return deselectedValue;
  }

  bool valueToBool(dynamic value) {
    if (value != null && value == selectedValue) return true;
    return false;
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
            value: valueToBool(this.value),
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
