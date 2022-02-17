import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/model/data/cell_editor_model.dart';

import '../../../components/dummy/fl_dummy_widget.dart';
import 'fl_dummy_model.dart';
import '../i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor<ICellEditorModel, dynamic> {
  FlDummyCellEditor({
    required Map<String, dynamic> pCellEditorJson,
  }) : super(
          model: ICellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: (_) {},
          onEndEditing: (_) {},
        );

  @override
  void dispose() {}

  @override
  FlStatelessWidget getWidget() {
    return FlDummyWidget(model: FlDummyModel());
  }

  @override
  void setValue(pValue) {}

  @override
  getValue() {}
}
