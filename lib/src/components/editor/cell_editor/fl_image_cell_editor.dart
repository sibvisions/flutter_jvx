import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../../../../util/constants/i_types.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/icon/fl_icon_model.dart';
import '../../../model/data/column_definition.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlImageCellEditor extends ICellEditor<ICellEditorModel, dynamic> {
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

  ColumnDefinition? _columnDefinition;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.recalculateSizeCallback,
  }) : super(
          columnDefinition: columnDefinition,
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

    recalculateSizeCallback?.call(true);
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    _columnDefinition = pColumnDefinition;

    recalculateSizeCallback?.call(true);
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return _columnDefinition;
  }

  @override
  FlStatelessWidget createWidget(BuildContext pContext) {
    FlIconModel widgetModel = FlIconModel();
    widgetModel.image = _value ?? '';

    return FlIconWidget(
      model: widgetModel,
      imageStreamListener: imageStreamListener,
      imageInBinary: _columnDefinition?.dataTypeIdentifier == Types.BINARY,
    );
  }

  @override
  FlComponentModel createWidgetModel() => FlIconModel();

  void onImage(Size pImageInfo, bool pSynchronousCall) {
    bool newSize = false;

    if (imageSize.height.toInt() != pImageInfo.height || imageSize.width.toInt() != pImageInfo.width) {
      log("new Size");
      imageSize = Size(pImageInfo.width.toDouble(), pImageInfo.height.toDouble());
      newSize = true;
      log("$imageSize");
    }

    if (!pSynchronousCall && newSize) {
      recalculateSizeCallback?.call(true);
    }
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

  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }

  @override
  Widget createTableWidget(BuildContext pContext) {
    return ConstrainedBox(
      child: createWidget(pContext),
      constraints: const BoxConstraints(
        maxHeight: 35,
        maxWidth: 35,
      ),
    );
  }
}
