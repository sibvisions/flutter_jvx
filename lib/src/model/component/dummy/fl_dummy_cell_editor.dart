import '../../../components/base_wrapper/fl_stateless_widget.dart';
import '../editor/cell_editor/cell_editor_model.dart';

import '../../../components/dummy/fl_dummy_widget.dart';
import 'fl_dummy_model.dart';
import '../../../components/editor/cell_editor/i_cell_editor.dart';

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
