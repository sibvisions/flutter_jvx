import 'package:flutter/material.dart';

import '../../../components/dummy/fl_dummy_widget.dart';
import 'fl_dummy_model.dart';
import '../i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor {
  @override
  late Widget widget;

  FlDummyCellEditor(Map<String, dynamic> pJson) {
    FlDummyModel model = FlDummyModel();
    model.applyFromJson(pJson);
    widget = FlDummyWidget(id: model.id, model: model);
  }
}
