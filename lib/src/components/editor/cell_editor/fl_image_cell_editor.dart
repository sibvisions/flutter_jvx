import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';
import 'package:flutter_client/util/constants/i_types.dart';

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/icon/fl_icon_model.dart';
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
  VoidCallback? imageLoadingCallback;

  /// The size of the image.
  Size imageSize = const Size(16, 16);

  /// The image loading callback.
  late ImageStreamListener imageStreamListener = ImageStreamListener(onImage);

  ColumnDefinition? _columnDefinition;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    required String id,
    required String name,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.imageLoadingCallback,
  }) : super(
          id: id,
          name: name,
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

    imageLoadingCallback?.call();
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    _columnDefinition = pColumnDefinition;

    imageLoadingCallback?.call();
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return _columnDefinition;
  }

  @override
  FlStatelessWidget getWidget(BuildContext pContext) {
    FlIconModel widgetModel = FlIconModel();
    widgetModel.image = _value ?? '';

    return FlIconWidget(
      model: widgetModel,
      imageStreamListener: imageStreamListener,
      imageInBinary: _columnDefinition?.dataTypeIdentifier == Types.BINARY,
    );
  }

  @override
  FlComponentModel getWidgetModel() => FlIconModel();

  void onImage(ImageInfo pImageInfo, bool pSynchronousCall) {
    if (imageSize.height.toInt() != pImageInfo.image.height || imageSize.width.toInt() != pImageInfo.image.width) {
      log("new Size");
      imageSize = Size(pImageInfo.image.width.toDouble(), pImageInfo.image.height.toDouble());
      log("$imageSize");
    }

    if (!pSynchronousCall) {
      imageLoadingCallback?.call();
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
}
