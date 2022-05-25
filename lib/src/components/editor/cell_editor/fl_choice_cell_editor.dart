import 'package:flutter/cupertino.dart';

import '../../../model/component/editor/cell_editor/fl_choice_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/icon/fl_icon_model.dart';
import '../../../model/data/column_definition.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlChoiceCellEditor extends ICellEditor<FlChoiceCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value of the editor.
  dynamic _value;

  int currentIndex = 0;

  /// The image loading callback to the editor.
  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  /// The size of the image.
  late Size imageSize = model.maxImageSize;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlChoiceCellEditor({
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.recalculateSizeCallback,
  }) : super(
          columnDefinition: columnDefinition,
          model: FlChoiceCellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        ) {
    model.imageLoadingCallback = recalculateSizeCallback;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;

    currentIndex = model.listValues.indexOf(_value);

    recalculateSizeCallback?.call(true);
  }

  @override
  FlStatelessWidget getWidget(BuildContext pContext) {
    FlIconModel widgetModel = FlIconModel();

    Widget image;
    if (currentIndex >= 0) {
      image = model.listImages[currentIndex];
    } else {
      image = model.defaultImage;
    }

    imageSize = model.maxImageSize;

    return FlIconWidget(
      model: widgetModel,
      directImage: image,
      onPress: onPress,
    );
  }

  void onPress() {
    currentIndex++;
    if (currentIndex >= model.listValues.length) {
      currentIndex = 0;
    }

    onEndEditing(model.listValues[currentIndex]);
  }

  @override
  FlComponentModel getWidgetModel() => FlIconModel();

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

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    // do nothing
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return null;
  }

  //TODO: implement this method
  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }
}
