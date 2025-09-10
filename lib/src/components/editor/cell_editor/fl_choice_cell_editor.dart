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

import '../../../model/component/editor/cell_editor/fl_choice_cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../icon/fl_icon_widget.dart';
import 'i_cell_editor.dart';

class FlChoiceCellEditor extends ICellEditor<FlIconModel, FlChoiceCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The value of the editor.
  dynamic _value;

  /// The index of the currently selected image
  int currentIndex = 0;

  /// Whether to use minimal size for widget and remove paddings and reduce tap target size
  bool? shrinkSize;

  /// The image loading callback to the editor.
  RecalculateCallback? recalculateSizeCallback;

  @override
  bool get allowedInTable => model.directCellEditor;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlChoiceCellEditor({
    required super.cellEditorJson,
    required super.dataProvider,
    required super.columnName,
    required super.columnDefinition,
    super.isInTable,
    this.shrinkSize,
    this.recalculateSizeCallback,
    required super.onValueChange,
    required super.onEndEditing,
  }) : super(
          model: FlChoiceCellEditorModel(),
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
  Widget createWidget(Map<String, dynamic>? pJson, [WidgetWrapper? pWrapper]) {
    FlIconModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    bool isEditable = true;
    if (pJson?.containsKey(ApiObjectProperty.cellEditorEditable) == true) {
      isEditable = pJson![ApiObjectProperty.cellEditorEditable];
    }

    return SizedBox(
      height: shrinkSize == true ? FlChoiceCellEditorModel.IMAGE_SIZE_MIN : model.imageSize,
      width: shrinkSize == true ? FlChoiceCellEditorModel.IMAGE_SIZE_MIN : model.imageSize,
      child: FlIconWidget(
        model: widgetModel,
        image: currentIndex >= 0 ? model.listImages[currentIndex] : model.defaultImage,
        inTable: isInTable,
        onPress: isEditable ? _onPress : null,
      ),
    );
  }

  void _onPress() {
    int index = currentIndex + 1;
    if (index >= model.listValues.length) {
      index = 0;
    }

    onEndEditing(model.listValues[index]);
  }

  @override
  createWidgetModel() => FlIconModel();

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
    return model.imageSize;
  }

  @override
  double getEditorHeight(Map<String, dynamic>? pJson) {
    return model.imageSize;
  }
}
