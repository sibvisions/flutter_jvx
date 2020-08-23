import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../../layout/i_alignment_constants.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import 'co_cell_editor.dart';

class CoCheckboxCellEditor extends CoCellEditor {
  dynamic selectedValue = true;
  dynamic deselectedValue = false;
  String text;

  CoCheckboxCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    selectedValue = changedCellEditor.getProperty<dynamic>(
        CellEditorProperty.SELECTED_VALUE, selectedValue);
    deselectedValue = changedCellEditor.getProperty<dynamic>(
        CellEditorProperty.DESELECTED_VALUE, deselectedValue);
    text = changedCellEditor.getProperty<String>(CellEditorProperty.TEXT, text);
  }

  factory CoCheckboxCellEditor.withCompContext(
      ComponentContext componentContext) {
    return CoCheckboxCellEditor(
        componentContext.cellEditor, componentContext.context);
  }

  void valueChanged(dynamic value) {
    this.value = boolToValue(value);
    this.onValueChanged(this.value);
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
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    setEditorProperties(
        editable: editable,
        background: background,
        foreground: foreground,
        placeholder: placeholder,
        font: font,
        horizontalAlignment: horizontalAlignment);

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
