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

import '../../../flutter_ui.dart';
import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../../util/parse_util.dart';
import '../password_field/fl_password_field_widget.dart';
import '../text_area/fl_text_area_widget.dart';
import '../text_field/fl_text_field_widget.dart';
import 'i_cell_editor.dart';

class FlTextCellEditor extends ICellEditor<FlTextFieldModel, FlTextFieldWidget, ICellEditorModel, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Content type for using a single line editor.
  static const String TEXT_PLAIN_SINGLELINE = "text/plain;singleline";

  /// Content type for using a multi line line editor.
  static const String TEXT_PLAIN_MULTILINE = "text/plain;multiline";

  /// Content type for using a multi line line editor.
  static const String TEXT_PLAIN_WRAPPEDMULTILINE = "text/plain;wrappedmultiline";

  /// Content type for using a multi line line editor.
  static const String TEXT_PLAIN_PASSWORD = "text/plain;password";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  FlTextFieldModel? lastWidgetModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.onFocusChanged,
    super.isInTable,
  }) : super(
          model: ICellEditorModel(),
        ) {
    focusNode.addListener(() {
      if (lastWidgetModel == null) {
        return;
      }

      var widgetModel = lastWidgetModel!;

      if (!widgetModel.isReadOnly) {
        if (!focusNode.hasFocus) {
          onEndEditing(textController.text);
        }
      }

      if (widgetModel.isFocusable) {
        onFocusChanged(focusNode.hasFocus);
      }
    });
  }

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

      textController.value = textController.value.copyWith(
        text: pValue,
        selection: TextSelection.collapsed(offset: pValue.characters.length),
        composing: null,
      );
    }
  }

  @override
  createWidget(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    switch (model.contentType) {
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        return FlTextAreaWidget(
          model: widgetModel as FlTextAreaModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
          inTable: isInTable,
          isMandatory: columnDefinition?.nullable == false,
        );
      case (TEXT_PLAIN_PASSWORD):
        return FlPasswordWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
          inTable: isInTable,
          isMandatory: columnDefinition?.nullable == false,
        );
      case (TEXT_PLAIN_SINGLELINE):
      default:
        return FlTextFieldWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
          inTable: isInTable,
          isMandatory: columnDefinition?.nullable == false,
        );
    }
  }

  @override
  createWidgetModel() {
    switch (model.contentType) {
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
    focusNode.dispose();
    textController.dispose();
  }

  @override
  String getValue() {
    return textController.text;
  }

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson) {
    if (!isInTable) {
      return createWidget(pJson).extraWidthPaddings();
    }

    return 0.0;
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson) {
    FlTextFieldModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    return (ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle()) * widgetModel.columns);
  }

  @override
  void tableEdit(Map<String, dynamic>? pJson) {
    IUiService()
        .openDialog(pBuilder: (context) => _buildPopupEditor(context, pJson), pIsDismissible: true)
        .then((value) {
      if (value != null) {
        onEndEditing(value);
      }
    });
  }

  Dialog _buildPopupEditor(BuildContext context, Map<String, dynamic>? pJson) {
    Size screenSize = MediaQuery.of(context).size;

    EdgeInsets paddingInsets;

    paddingInsets = EdgeInsets.fromLTRB(
      screenSize.width / 16,
      screenSize.height / 16,
      screenSize.width / 16,
      screenSize.height / 16,
    );

    FlTextFieldModel searchFieldModel = FlTextFieldModel();
    searchFieldModel.fontSize = 14;

    List<Widget> listBottomButtons = [];

    if (columnDefinition?.nullable == true) {
      listBottomButtons.add(
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Builder(
                builder: (context) => Text(
                  style: TextStyle(
                    shadows: [
                      Shadow(
                        offset: const Offset(0, -2),
                        color: DefaultTextStyle.of(context).style.color!,
                      )
                    ],
                    color: Colors.transparent,
                    decoration: TextDecoration.underline,
                    decorationColor: DefaultTextStyle.of(context).style.color,
                    decorationThickness: 1,
                  ),
                  FlutterUI.translate("No value"),
                ),
              ),
            ),
          ),
        ),
      );
    }

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            child: Text(
              FlutterUI.translate("Cancel"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );

    return Dialog(
      insetPadding: paddingInsets,
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterUI.translate("Edit ${columnDefinition?.label}"),
              style: Theme.of(context).dialogTheme.titleTextStyle,
            ),
            const SizedBox(height: 8),
            createWidget(pJson),
            const SizedBox(height: 8),
            Row(
              children: listBottomButtons,
            ),
          ],
        ),
      ),
    );
  }
}
