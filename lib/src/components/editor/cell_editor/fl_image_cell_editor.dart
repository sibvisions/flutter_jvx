import 'package:flutter/cupertino.dart';
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

  /// The image loading callback to the editor.
  VoidCallback? imageLoadingCallback;

  /// The size of the image.
  Size imageSize = Size.zero;

  /// The image loading callback.
  late ImageStreamListener imageStreamListener = ImageStreamListener(onImage);
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.imageLoadingCallback,
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

    return FlIconWidget(model: widgetModel, imageStreamListener: imageStreamListener);
  }

  void onImage(ImageInfo pImageInfo, bool pSynchronousCall) {
    if (imageSize.height.toInt() != pImageInfo.image.height || imageSize.width.toInt() != pImageInfo.image.width) {
      imageSize = Size(pImageInfo.image.width.toDouble(), pImageInfo.image.height.toDouble());
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
