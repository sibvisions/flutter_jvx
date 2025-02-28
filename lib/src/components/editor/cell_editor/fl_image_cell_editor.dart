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
import '../../../util/icon_util.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlImageCellEditor extends ICellEditor<FlIconModel, FlImageCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The image of the icon.
  String? _value;

  ImageProvider? imageProvider;

  /// The image loading callback to the editor.
  RecalculateCallback? recalculateSizeCallback;

  /// The size of the image.
  Size imageSize = const Size.square(IconUtil.DEFAULT_ICON_SIZE);

  /// The image loading callback.
  late Function(Size, bool)? imageStreamListener = onImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlImageCellEditor({
    required super.cellEditorJson,
    required super.dataProvider,
    required super.columnName,
    required super.columnDefinition,
    super.isInTable,
    this.recalculateSizeCallback,
    required super.onValueChange,
    required super.onEndEditing,
  }) : super(model: FlImageCellEditorModel());

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
  createWidget(Map<String, dynamic>? pJson) {
    FlIconModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);
    widgetModel.originalSize = imageSize;

    return FlIconWidget(
      model: widgetModel,
      imageStreamListener: onImage,
      inTable: isInTable,
    );
  }

  @override
  createWidgetModel() {
    FlIconModel widgetModel = FlIconModel();

    if (isInTable) {
      widgetModel.horizontalAlignment = HorizontalAlignment.LEFT;
    }

    widgetModel.image = _value ?? model.defaultImageName;
    widgetModel.preserveAspectRatio = model.preserveAspectRatio;

    return widgetModel;
  }

  @override
  Future<dynamic> getValue() async {
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
  double getEditorHeight(Map<String, dynamic>? pJson) {
    return imageSize.height;
  }

  @override
  bool get allowedInTable => true;

  void onImage(Size pImageInfo, bool pSynchronousCall) {
    bool newSize = false;

    if (imageSize.height.toDouble() != pImageInfo.height || imageSize.width.toDouble() != pImageInfo.width) {
      imageSize = Size(pImageInfo.width.toDouble(), pImageInfo.height.toDouble());
      newSize = true;
    }

    if (!pSynchronousCall && newSize) {
      recalculateSizeCallback?.call(true);
    }
  }
}
