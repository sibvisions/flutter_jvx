import 'package:flutter/widgets.dart';

import '../../../model/component/editor/cell_editor/fl_choice_cell_editor_model.dart';
import '../../../model/component/icon/fl_icon_model.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlChoiceCellEditor extends ICellEditor<FlIconModel, FlIconWidget, FlChoiceCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value of the editor.
  dynamic _value;

  int currentIndex = 0;

  /// The image loading callback to the editor.
  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  /// The size of the image.
  late Size imageSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlChoiceCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    this.recalculateSizeCallback,
  }) : super(
          model: FlChoiceCellEditorModel(),
        ) {
    model.imageLoadingCallback = recalculateSizeCallback;
    imageSize = model.maxImageSize;
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
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlIconModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

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
      inTable: pInTable,
      onPress: onPress,
    );
  }

  @override
  bool canBeInTable() => true;

  void onPress() {
    currentIndex++;
    if (currentIndex >= model.listValues.length) {
      currentIndex = 0;
    }

    onEndEditing(model.listValues[currentIndex]);
  }

  @override
  createWidgetModel() => FlIconModel();

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  void dispose() {
    // do nothing
  }

  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }

  @override
  double get additionalTablePadding => 0.0;
}
