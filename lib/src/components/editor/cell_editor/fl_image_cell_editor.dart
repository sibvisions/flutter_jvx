import 'package:flutter_client/src/components/icon/fl_icon_widget.dart';
import 'package:flutter_client/src/model/component/icon/fl_icon_model.dart';

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import 'i_cell_editor.dart';

class FlImageCellEditor extends ICellEditor<ICellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  dynamic _value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
  }) : super(
          model: ICellEditorModel(),
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
  FlStatelessWidget getWidget() {
    FlIconModel widgetModel = FlIconModel();
    widgetModel.image = _value ?? '';

    return FlIconWidget(model: widgetModel);
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
  bool isActionCellEditor() {
    return false;
  }
}
