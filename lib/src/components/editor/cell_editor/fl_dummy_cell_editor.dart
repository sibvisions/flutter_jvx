import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';

import '../../../model/component/dummy/fl_dummy_model.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../dummy/fl_dummy_widget.dart';
import 'i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor<ICellEditorModel, dynamic> {
  FlDummyCellEditor()
      : super(
          id: "",
          name: "",
          columnName: "",
          model: ICellEditorModel(),
          pCellEditorJson: {},
          onValueChange: (_) {},
          onEndEditing: (_) {},
        );

  @override
  void dispose() {}

  @override
  FlStatelessWidget getWidget(BuildContext pContext) {
    return FlDummyWidget(model: FlDummyModel());
  }

  @override
  FlComponentModel getWidgetModel() => FlDummyModel();

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
}
