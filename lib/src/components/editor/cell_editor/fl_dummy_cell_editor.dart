import '../../../model/component/dummy/fl_dummy_model.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../dummy/fl_dummy_widget.dart';
import 'i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor<FlDummyModel, FlDummyWidget, ICellEditorModel, dynamic> {
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
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    return FlDummyWidget(model: createWidgetModel());
  }

  @override
  FlDummyModel createWidgetModel() => FlDummyModel();

  @override
  void setValue(pValue) {}

  @override
  getValue() {}

  @override
  bool isActionCellEditor() {
    return false;
  }

  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }

  @override
  FlDummyWidget? createTableWidget() {
    return null;
  }

  @override
  double get additionalTablePadding => 0.0;
}
