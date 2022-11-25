import '../../../model/component/dummy/fl_dummy_model.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../dummy/fl_dummy_widget.dart';
import 'i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor<FlDummyModel, FlDummyWidget, ICellEditorModel, dynamic> {
  dynamic _value;

  FlDummyCellEditor()
      : super(
          model: ICellEditorModel(),
          pCellEditorJson: {},
          onValueChange: _doNothing,
          onEndEditing: _doNothing,
          onFocusChanged: _doNothing,
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
  void setValue(pValue) {
    _value = pValue;
  }

  @override
  dynamic getValue() {
    return _value;
  }

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

  static void _doNothing(dynamic ignore) {}
}
