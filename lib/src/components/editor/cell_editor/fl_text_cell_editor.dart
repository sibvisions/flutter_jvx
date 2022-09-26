import 'package:flutter/widgets.dart';

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextCellEditor({
    required super.columnDefinition,
    required super.pCellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
  }) : super(
          model: ICellEditorModel(),
        ) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        onEndEditing(textController.text);
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
  createWidget(Map<String, dynamic>? pJson, bool pInTable) {
    FlTextFieldModel widgetModel = createWidgetModel();

    ICellEditor.applyEditorJson(widgetModel, pJson);

    switch (model.contentType) {
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        return FlTextAreaWidget(
          model: widgetModel as FlTextAreaModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
        );
      case (TEXT_PLAIN_PASSWORD):
        return FlPasswordWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
        );
      case (TEXT_PLAIN_SINGLELINE):
      default:
        return FlTextFieldWidget(
          model: widgetModel,
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
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
  String formatValue(Object pValue) {
    return pValue.toString();
  }

  @override
  double get additionalTablePadding => 0.0;
}
