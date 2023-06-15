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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../util/parse_util.dart';
import '../password_field/fl_password_field_widget.dart';
import '../text_area/fl_text_area_widget.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlTextCellEditor extends IFocusableCellEditor<FlTextFieldModel, ICellEditorModel, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Content type for using a single line editor.
  static const String TEXT_PLAIN_SINGLELINE = "text/plain;singleline";

  /// Content type for using a multi line line editor.
  static const String TEXT_PLAIN_MULTILINE = "text/plain;multiline";

  /// Content type for using a multi line line editor.
  static const String TEXT_PLAIN_WRAPPEDMULTILINE = "text/plain;wrappedmultiline";

  /// Content type for using a single line password editor.
  static const String TEXT_PLAIN_PASSWORD = "text/plain;password";

  /// Content type for using a multi line html editor.
  static const String TEXT_HTML = "text/html";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController textController = TextEditingController();

  /// If the [HtmlEditor] has been initialized.
  bool htmlInitialized = false;

  /// The last created Widget.
  FlTextFieldModel? lastWidgetModel;

  /// If the cell editor is an html editor.
  bool get isHtml => model.contentType == TEXT_HTML;

  /// If the cell editor is initialized.
  bool get isInitialized => !isHtml || htmlInitialized;

  /// The last value.
  dynamic lastSentValue;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextCellEditor({
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.columnName,
    required super.dataProvider,
    super.onFocusChanged,
    super.isInTable,
  }) : super(
          model: ICellEditorModel(),
        );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    if (pValue == null) {
      textController.clear();
    } else {
      if (pValue is! String) {
        pValue = pValue.toString();
      }

      textController.value =
          TextEditingValue(text: pValue, selection: TextSelection.collapsed(offset: pValue.runes.length));
    }
  }

  @override
  Widget createWidget(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    var textLimitFormatter =
        LengthLimitingTextInputFormatter(columnDefinition?.length, maxLengthEnforcement: MaxLengthEnforcement.enforced);

    switch (model.contentType) {
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
      case (TEXT_HTML):
        return FlTextAreaWidget(
          model: widgetModel as FlTextAreaModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
          isMandatory: columnDefinition?.nullable == false,
          inputFormatters: [textLimitFormatter],
          hideClearIcon: columnDefinition?.nullable == false || model.hideClearIcon,
        );
      case (TEXT_PLAIN_PASSWORD):
        return FlPasswordWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
          isMandatory: columnDefinition?.nullable == false,
          inputFormatters: [textLimitFormatter],
          hideClearIcon: columnDefinition?.nullable == false || model.hideClearIcon,
        );
      case (TEXT_PLAIN_SINGLELINE):
      default:
        return FlTextFieldWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
          isMandatory: columnDefinition?.nullable == false,
          inputFormatters: [textLimitFormatter],
          hideClearIcon: columnDefinition?.nullable == false || model.hideClearIcon,
        );
    }
  }

  @override
  createWidgetModel() {
    switch (model.contentType) {
      case (TEXT_HTML):
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        return FlTextAreaModel();
      case (TEXT_PLAIN_SINGLELINE):
        return FlTextFieldModel();
      case (TEXT_PLAIN_PASSWORD):
        return FlTextFieldModel();
      default:
        return FlTextFieldModel();
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Future<String> getValue() async {
        return textController.text;
  }

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double getEditorHeight(Map<String, dynamic>? pJson) {
    switch (model.contentType) {
      case (TEXT_HTML):
        return 250;
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        FlTextAreaModel widgetModel = FlTextAreaModel();
        applyEditorJson(widgetModel, pJson);
        return FlTextAreaWidget.calculateTextAreaHeight(widgetModel);
      case (TEXT_PLAIN_SINGLELINE):
      case (TEXT_PLAIN_PASSWORD):
      default:
        return FlTextFieldWidget.TEXT_FIELD_HEIGHT;
    }
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    return (ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle()) * widgetModel.columns);
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson) {
      return (createWidget(pJson) as FlTextFieldWidget).extraWidthPaddings();
    }
  }

  @override
  bool firesFocusCallback() {
    if (lastWidgetModel == null) {
      return false;
    }

    return lastWidgetModel!.isFocusable;
  }

  @override
  Future<void> focusChanged(bool pHasFocus) async {
    if (lastWidgetModel == null || !isInitialized) {
      return;
    }

    var widgetModel = lastWidgetModel!;

    if (!widgetModel.isReadOnly) {
      if (!pHasFocus) {
        onEndEditing(await getValue());
      }
    }

    super.focusChanged(pHasFocus);
  }
}
