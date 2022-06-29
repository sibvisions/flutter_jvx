import 'package:flutter/material.dart';

import '../../../model/component/dummy/fl_dummy_model.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../dummy/fl_dummy_widget.dart';
import 'i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor<ICellEditorModel, dynamic> {
  FlDummyCellEditor()
      : super(
          model: ICellEditorModel(),
          pCellEditorJson: {},
          onValueChange: (_) {},
          onEndEditing: (_) {},
        );

  @override
  void dispose() {}

  @override
  FlStatelessWidget createWidget(BuildContext pContext) {
    return FlDummyWidget(model: FlDummyModel());
  }

  @override
  FlComponentModel createWidgetModel() => FlDummyModel();

  @override
  void setValue(pValue) {}

  @override
  getValue() {}

  @override
  bool isActionCellEditor() {
    return false;
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    // do nothing
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return null;
  }

  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }

  @override
  FlStatelessWidget? createTableWidget(BuildContext pContext) {
    return null;
  }
}
