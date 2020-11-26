import 'package:flutter/material.dart';

import '../../../ui/layout/i_alignment_constants.dart';
import 'co_cell_editor_widget.dart';
import 'models/checkbox_cell_editor_model.dart';

class CoCheckboxCellEditorWidget extends CoCellEditorWidget {
  final CheckBoxCellEditorModel cellEditorModel;

  CoCheckboxCellEditorWidget({
    this.cellEditorModel,
    Key key,
  }) : super(
          cellEditorModel: cellEditorModel,
          key: key,
        );

  @override
  State<StatefulWidget> createState() => CoCheckboxCellEditorWidgetState();
}

class CoCheckboxCellEditorWidgetState
    extends CoCellEditorWidgetState<CoCheckboxCellEditorWidget> {
  @override
  void initState() {
    super.initState();
  }

  void valueChanged(dynamic value) {
    widget.cellEditorModel.cellEditorValue = widget.cellEditorModel.boolToValue(value);
    this.onValueChanged(
        widget.cellEditorModel.cellEditorValue, widget.cellEditorModel.indexInTable);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //     color: background != null ? background : Colors.transparent,
      //     borderRadius: BorderRadius.circular(5),
      //     border:
      //         borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: Row(
        mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
            widget.cellEditorModel.horizontalAlignment),
        children: <Widget>[
          Checkbox(
            value: widget.cellEditorModel
                .valueToBool(widget.cellEditorModel.cellEditorValue),
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
