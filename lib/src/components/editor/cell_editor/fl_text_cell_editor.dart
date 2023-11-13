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
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../util/parse_util.dart';
import '../password_field/fl_password_field_widget.dart';
import '../text_area/fl_text_area_widget.dart';
import '../text_field/fl_html_text_field_widget.dart';
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

  /// The [HtmlEditorController] of the [HtmlEditor] widget.
  final HtmlEditorController htmlController = HtmlEditorController();

  // /// The [HtmlEditorController] of the [QuillHtmlEditor] widget.
  // final QuillEditorController htmlController = QuillEditorController();

  /// The [TextEditingController] of the [TextField] widget.
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
  dynamic lastReceivedValue;

  /// The last sent value;
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
    lastReceivedValue = pValue;

    if (isInitialized && getValue() != pValue) {
      if (pValue == null) {
        if (isHtml) {
          htmlController.clear();
        } else {
          textController.clear();
        }
      } else {
        if (pValue is! String) {
          pValue = pValue.toString();
        }

        if (isHtml) {
          htmlController.setText(pValue);
        } else {
          textController.value = TextEditingValue(
            text: pValue,
            selection: TextSelection.collapsed(
              offset: pValue.runes.length,
            ),
          );
        }
      }
    }
  }

  @override
  Widget createWidget(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    var textLimitFormatter =
        LengthLimitingTextInputFormatter(columnDefinition?.length, maxLengthEnforcement: MaxLengthEnforcement.enforced);

    _fixEditorEnableStatus();

    switch (model.contentType) {
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
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
      case (TEXT_HTML):
        return FlHtmlTextFieldWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          htmlController: htmlController,
          onFocusChanged: focusChanged,
          onInit: () {
            htmlInitialized = true;
            setValue(lastReceivedValue);
            _fixEditorEnableStatus();
          },
        );
      // return FlQuillHtmlTextFieldWidget(
      //   model: widgetModel,
      //   valueChanged: onValueChange,
      //   endEditing: onEndEditing,
      //   htmlController: htmlController,
      //   focusNode: focusNode,
      //   onInit: () {
      //     htmlInitialized = true;
      //     setValue(lastReceivedValue);
      //   },
      // );
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
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        return FlTextAreaModel();
      case (TEXT_HTML):
      case (TEXT_PLAIN_SINGLELINE):
      case (TEXT_PLAIN_PASSWORD):
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
  Future<String?> getValue() async {
    if (isInitialized) {
      if (isHtml) {
        var html = await htmlController.getText();

        if (html.isNotEmpty) {
          if (!html.startsWith("<html>")) {
            html = "<html>$html";
          }

          if (!html.endsWith("</html>")) {
            html = "$html</html>";
          }
        }

        return html;
      } else {
        return textController.text;
      }
    }

    return null;
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
    if (isHtml) {
      return 250;
    }

    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    return (ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle()) * widgetModel.columns);
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson) {
    if (isHtml) {
      return 0;
    } else {
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
        lastSentValue = await getValue();
        onEndEditing(lastSentValue);
      }
    }

    super.focusChanged(pHasFocus);
  }

  /// The [HtmlEditor] does not update its status of enable/disable on its own through the constructor.
  ///
  /// Instead, it must be handled by the controller but only after having been initialized.
  void _fixEditorEnableStatus() {
    if (isInitialized && isHtml && lastWidgetModel != null) {
      if (lastWidgetModel!.isReadOnly) {
        htmlController.disable();
      } else {
        htmlController.enable();
      }
    }
  }
}
