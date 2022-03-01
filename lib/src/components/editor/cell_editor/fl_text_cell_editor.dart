import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/components/dummy/fl_dummy_widget.dart';
import 'package:flutter_client/src/components/editor/password_field/fl_password_widget.dart';
import 'package:flutter_client/src/components/editor/text_area/fl_text_area_widget.dart';
import 'package:flutter_client/src/components/editor/text_field/fl_text_field_widget.dart';
import 'package:flutter_client/src/model/component/dummy/fl_dummy_model.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_area_model.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import 'package:flutter_client/src/model/data/cell_editor_model.dart';
import '../../../model/component/i_cell_editor.dart';

class FlTextCellEditor extends ICellEditor<ICellEditorModel, String> {
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
    required Map<String, dynamic> pCellEditorJson,
    required Function(String) onChange,
    required Function(String) onEndEditing,
  }) : super(
          model: ICellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
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
  void setValue(String? pValue) {
    if (pValue == null) {
      textController.clear();
    } else {
      textController.value = textController.value.copyWith(
        text: pValue,
        selection: TextSelection.collapsed(offset: pValue.characters.length),
        composing: null,
      );
    }
  }

  @override
  FlStatelessWidget getWidget() {
    switch (model.contentType) {
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        return FlTextAreaWidget(
          model: FlTextAreaModel(),
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
        );
      case (TEXT_PLAIN_SINGLELINE):
        return FlTextFieldWidget(
          model: FlTextFieldModel(),
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
        );
      case (TEXT_PLAIN_PASSWORD):
        return FlPasswordWidget(
          model: FlTextFieldModel(),
          valueChanged: onValueChange,
          endEditing: onEndEditing,
          focusNode: focusNode,
          textController: textController,
        );
      default:
        return FlDummyWidget(model: FlDummyModel());
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
}
