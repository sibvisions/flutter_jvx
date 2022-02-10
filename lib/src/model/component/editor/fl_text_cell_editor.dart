import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/editor/PasswordField/fl_password_widget.dart';
import 'package:flutter_client/src/components/editor/TextArea/fl_text_area_widget.dart';
import 'package:flutter_client/src/components/editor/TextField/fl_text_field_widget.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_area_model.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import '../../../components/dummy/fl_dummy_widget.dart';
import '../../api/api_object_property.dart';
import '../dummy/fl_dummy_model.dart';
import '../i_cell_editor.dart';

class FlTextCellEditor extends ICellEditor {
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

  late Widget _widget;

  @override
  Widget get widget => _widget;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextCellEditor(Map<String, dynamic> pJson) {
    Map<String, dynamic> cellEditorJson = pJson[ApiObjectProperty.cellEditor];
    String contentType = cellEditorJson[ApiObjectProperty.contentType];

    switch (contentType) {
      case (TEXT_PLAIN_WRAPPEDMULTILINE):
      case (TEXT_PLAIN_MULTILINE):
        _widget = createTextAreaWidget(pJson, cellEditorJson);
        break;

      case (TEXT_PLAIN_SINGLELINE):
        _widget = createTextFieldWidget(pJson, cellEditorJson);
        break;

      case (TEXT_PLAIN_PASSWORD):
        _widget = createPasswordWidget(pJson, cellEditorJson);
        break;

      default:
        FlDummyModel model = FlDummyModel();
        model.applyFromJson(pJson);
        _widget = FlDummyWidget(id: model.id, model: model);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextAreaWidget createTextAreaWidget(Map<String, dynamic> pJson, Map<String, dynamic> pCellEditorJson) {
    FlTextAreaModel model = FlTextAreaModel();
    model.applyFromJson(pJson);

    model.applyFromJson(pCellEditorJson);

    model.applyCellEditorOverrides(pJson);

    return FlTextAreaWidget(
        model: model,
        valueChanged: valueChanged,
        endEditing: endEditing,
        focusNode: focusNode,
        textController: textController);
  }

  FlTextFieldWidget createTextFieldWidget(Map<String, dynamic> pJson, Map<String, dynamic> pCellEditorJson) {
    FlTextFieldModel model = FlTextFieldModel();
    model.applyFromJson(pJson);

    model.applyFromJson(pCellEditorJson);

    model.applyCellEditorOverrides(pJson);

    return FlTextFieldWidget(
        model: model,
        valueChanged: valueChanged,
        endEditing: endEditing,
        focusNode: focusNode,
        textController: textController);
  }

  FlTextFieldWidget createPasswordWidget(Map<String, dynamic> pJson, Map<String, dynamic> pCellEditorJson) {
    FlTextFieldModel model = FlTextFieldModel();
    model.applyFromJson(pJson);

    model.applyFromJson(pCellEditorJson);

    model.applyCellEditorOverrides(pJson);

    return FlPasswordWidget(
        model: model,
        valueChanged: valueChanged,
        endEditing: endEditing,
        focusNode: focusNode,
        textController: textController);
  }

  void valueChanged(String pValue) {
    // if (pValue != model.text) {
    //   log("Value changed to: " + pValue + " | Length: " + pValue.characters.length.toString());

    //   setState(() {
    //     model.text = pValue;
    //   });
    // }
  }

  void endEditing(String pValue) {
    // log("Editing ended with: " + pValue + " | Length: " + pValue.characters.length.toString());

    // setState(() {
    //   model.text = pValue;
    // });
  }

  void updateText() {
    // textController.value = textController.value.copyWith(
    //   text: model.text,
    //   selection: TextSelection.collapsed(offset: model.text.characters.length),
    //   composing: null,
    // );
  }
}
