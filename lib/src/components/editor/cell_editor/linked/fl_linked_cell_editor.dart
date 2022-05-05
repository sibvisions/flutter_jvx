import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/editor/cell_editor/linked/fl_linked_cell_picker.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';

import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/data/column_definition.dart';
import '../i_cell_editor.dart';
import 'fl_linked_editor_widget.dart';

class FlLinkedCellEditor extends ICellEditor<FlLinkedCellEditorModel, dynamic> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  dynamic _value;

  TextEditingController textController = TextEditingController();

  FocusNode focusNode = FocusNode();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor({
    required String id,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
  }) : super(
          id: id,
          model: FlLinkedCellEditorModel(),
          pCellEditorJson: pCellEditorJson,
          onValueChange: onChange,
          onEndEditing: onEndEditing,
        ) {
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
          openLinkedCellPicker();
        }
      },
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;

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
  FlLinkedEditorWidget getWidget(BuildContext pContext) {
    FlLinkedEditorModel widgetModel = FlLinkedEditorModel();

    return FlLinkedEditorWidget(
      model: widgetModel,
      endEditing: onEndEditing,
      valueChanged: onValueChange,
      textController: textController,
      focusNode: focusNode,
      onPress: openLinkedCellPicker,
    );
  }

  void openLinkedCellPicker() {
    FocusManager.instance.primaryFocus?.unfocus();

    uiService
        .openDialog(
            pDialogWidget: FlLinkedCellPicker(
              model: model,
              id: id,
            ),
            pIsDismissible: true)
        .then((value) {
      if (value != null) {
        onEndEditing(value);
      }
    });
  }

  @override
  FlLinkedEditorModel getWidgetModel() => FlLinkedEditorModel();

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
  }

  @override
  String getValue() {
    return _value;
  }

  @override
  bool isActionCellEditor() {
    return true;
  }

  @override
  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    // do nothing
  }

  @override
  ColumnDefinition? getColumnDefinition() {
    return null;
  }
}
