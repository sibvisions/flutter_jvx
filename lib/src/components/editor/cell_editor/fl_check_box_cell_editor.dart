import 'package:flutter/cupertino.dart';

import '../../../model/component/check_box/fl_check_box_model.dart';
import '../../../model/component/editor/cell_editor/fl_check_box_cell_editor_model.dart';
import '../../check_box/fl_check_box_widget.dart';
import 'i_cell_editor.dart';

class FlCheckBoxCellEditor extends ICellEditor<FlCheckBoxModel, FlCheckBoxWidget, FlCheckBoxCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FocusNode focusNode = FocusNode();

  /// The value of the check box.
  dynamic _value;

  FlCheckBoxModel? lastWidgetModel;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.onFocusChanged,
  }) : super(
          model: FlCheckBoxCellEditorModel(),
        ) {
    focusNode.addListener(() {
      if (lastWidgetModel == null) {
        return;
      }

      var widgetModel = lastWidgetModel!;

      if (widgetModel.isFocusable) {
        onFocusChanged(focusNode.hasFocus);
      }
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;
  }

  @override
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlCheckBoxModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    return FlCheckBoxWidget(
      focusNode: focusNode, // TODO: FOCUS NODE
      model: widgetModel,
      onPress: onPress,
      inTable: pInTable,
    );
  }

  @override
  createWidgetModel() {
    FlCheckBoxModel widgetModel = FlCheckBoxModel();

    widgetModel.labelModel.text = model.text;
    widgetModel.selected = model.selectedValue == _value;

    return widgetModel;
  }

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  void dispose() {
    // do nothing
  }

  @override
  bool get canBeInTable => true;

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson, bool pInTable) {
    return 0.0;
  }

  @override
  double? getEditorSize(Map<String, dynamic>? pJson, bool pInTable) {
    return null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void onPress() {
    if (_value == model.selectedValue) {
      onEndEditing(model.deselectedValue);
    } else {
      onEndEditing(model.selectedValue);
    }
  }
}
