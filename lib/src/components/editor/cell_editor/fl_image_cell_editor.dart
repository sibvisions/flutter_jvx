import 'package:flutter/widgets.dart';

import '../../../model/component/editor/cell_editor/fl_image_cell_editor_model.dart';
import '../../../model/component/icon/fl_icon_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/layout/alignments.dart';
import '../../../util/i_types.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlImageCellEditor extends ICellEditor<FlIconModel, FlIconWidget, FlImageCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  dynamic _value;

  /// The image loading callback to the editor.
  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  /// The size of the image.
  Size imageSize = const Size(16, 16);

  /// The image loading callback.
  late Function(Size, bool)? imageStreamListener = onImage;

  /// If the cell editor is currently showing the default image.
  bool pDefaultImageUsed = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    this.recalculateSizeCallback,
  }) : super(
          model: FlImageCellEditorModel(),
        );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;

    recalculateSizeCallback?.call(true);
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    super.setColumnDefinition(pColumnDefinition);

    recalculateSizeCallback?.call(true);
  }

  @override
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlIconModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    if (pInTable) {
      widgetModel.horizontalAlignment = HorizontalAlignment.LEFT;
    }

    return FlIconWidget(
      model: widgetModel,
      imageStreamListener: imageStreamListener,
      imageInBinary: !pDefaultImageUsed && columnDefinition?.dataTypeIdentifier == Types.BINARY,
      inTable: pInTable,
    );
  }

  @override
  createWidgetModel() {
    FlIconModel widgetModel = FlIconModel();

    widgetModel.image = _value ?? "";
    widgetModel.preserveAspectRatio = model.preserveAspectRatio;

    pDefaultImageUsed = false;
    if (widgetModel.image.isEmpty) {
      widgetModel.image = model.defaultImageName;
      pDefaultImageUsed = true;
    }

    return widgetModel;
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
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson, bool pInTable) {
    return 0.0;
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson, bool pInTable) {
    return imageSize.width;
  }

  @override
  bool get canBeInTable => true;

  void onImage(Size pImageInfo, bool pSynchronousCall) {
    bool newSize = false;

    if (imageSize.height.toInt() != pImageInfo.height || imageSize.width.toInt() != pImageInfo.width) {
      imageSize = Size(pImageInfo.width.toDouble(), pImageInfo.height.toDouble());
      newSize = true;
    }

    if (!pSynchronousCall && newSize) {
      recalculateSizeCallback?.call(true);
    }
  }
}
