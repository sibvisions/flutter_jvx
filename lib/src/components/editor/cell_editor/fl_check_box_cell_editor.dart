import '../../../model/component/check_box/fl_check_box_model.dart';
import '../../../model/component/editor/cell_editor/fl_check_box_cell_editor_model.dart';
import '../../../model/data/column_definition.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../check_box/fl_check_box_widget.dart';
import 'i_cell_editor.dart';

class FlCheckBoxCellEditor extends ICellEditor<FlCheckBoxCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value of the check box.
  dynamic _value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxCellEditor({
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
  }) : super(
          columnDefinition: columnDefinition,
          model: FlCheckBoxCellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;
  }

  @override
  FlStatelessWidget createWidget() {
    FlCheckBoxModel widgetModel = FlCheckBoxModel();
    widgetModel.labelModel.text = model.text;
    widgetModel.selected = model.selectedValue == _value;

    return FlCheckBoxWidget(model: widgetModel, onPress: onPress);
  }

  @override
  FlCheckBoxModel createWidgetModel() => FlCheckBoxModel();

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  void dispose() {
    // do nothing
  }

  @override
  bool isActionCellEditor() {
    return true;
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    // do nothing
  }

  @override
  ColumnDefinition? getColumnDefinition() {
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

  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }

  @override
  FlStatelessWidget? createTableWidget() {
    return createWidget();
  }

  @override
  double get additionalTablePadding => 0.0;
}
