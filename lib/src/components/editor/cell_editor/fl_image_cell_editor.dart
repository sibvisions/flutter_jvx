/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/widgets.dart';

import '../../../model/component/editor/cell_editor/fl_image_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/data/column_definition.dart';
import '../../../model/layout/alignments.dart';
import '../../../util/i_types.dart';
import '../../../util/image/image_loader.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlImageCellEditor extends ICellEditor<FlIconModel, FlIconWidget, FlImageCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  String? _value;

  ImageProvider? imageProvider;

  /// The image loading callback to the editor.
  RecalculateCallback? recalculateSizeCallback;

  /// The size of the image.
  Size imageSize = const Size(16, 16);

  /// The image loading callback.
  late Function(Size, bool)? imageStreamListener = onImage;

  /// If the cell editor is currently showing the default image.
  bool defaultImageUsed = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.columnName,
    required super.dataProvider,
    this.recalculateSizeCallback,
    super.isInTable,
  }) : super(model: FlImageCellEditorModel()) {
    _updateImageProvider();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    String? oldValue = _value;
    _value = pValue;

    if (oldValue != pValue) {
      _updateImageProvider();
    }
    recalculateSizeCallback?.call(true);
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    super.setColumnDefinition(pColumnDefinition);

    _updateImageProvider();
    recalculateSizeCallback?.call(true);
  }

  void _updateImageProvider() {
    defaultImageUsed = false;
    if (_value?.isEmpty ?? true) {
      defaultImageUsed = true;
    }

    imageProvider = ImageLoader.getImageProvider(
      !defaultImageUsed ? _value : model.defaultImageName,
      pImageStreamListener: imageStreamListener,
      pImageInBase64: !defaultImageUsed && columnDefinition?.dataTypeIdentifier == Types.BINARY,
    );
  }

  @override
  createWidget(Map<String, dynamic>? pJson) {
    FlIconModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    return FlIconWidget(
      model: widgetModel,
      imageProvider: imageProvider,
      inTable: isInTable,
    );
  }

  @override
  createWidgetModel() {
    FlIconModel widgetModel = FlIconModel();

    if (isInTable) {
      widgetModel.horizontalAlignment = HorizontalAlignment.LEFT;
    }

    widgetModel.image = _value ?? "";
    widgetModel.preserveAspectRatio = model.preserveAspectRatio;

    if (defaultImageUsed) {
      widgetModel.image = model.defaultImageName;
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
  double getEditorWidth(Map<String, dynamic>? pJson) {
    return imageSize.width;
  }

  @override
  bool get allowedInTable => true;

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
