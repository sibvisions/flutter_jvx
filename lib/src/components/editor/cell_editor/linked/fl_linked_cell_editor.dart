import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../../mixin/ui_service_mixin.dart';
import '../../../../model/command/api/filter_command.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';
import '../i_cell_editor.dart';
import 'fl_linked_cell_picker.dart';
import 'fl_linked_editor_widget.dart';

class FlLinkedCellEditor extends ICellEditor<FlLinkedCellEditorModel, dynamic> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final HashMap<dynamic, dynamic> _valueMap = HashMap();

  final int pageLoad = 50;

  int currentPage = 1;

  bool lastCallbackIntentional = true;

  bool isAllFetched = false;

  dynamic _value;

  TextEditingController textController = TextEditingController();

  FocusNode focusNode = FocusNode();

  CellEditorRecalculateSizeCallback? recalculateSizeCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor({
    String? id,
    String? name,
    String? columnName,
    ColumnDefinition? columnDefinition,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.recalculateSizeCallback,
  }) : super(
          id: id,
          name: name,
          columnName: columnName,
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
    subscribe();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;

    setValueIntoController();
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

    uiService.sendCommand(
      FilterCommand(
          editorId: name!,
          value: "",
          dataProvider: model.linkReference.dataProvider,
          reason: "Opened the linked cell picker"),
    );

    uiService
        .openDialog(
            pDialogWidget: FlLinkedCellPicker(
              model: model,
              id: id!,
              name: name!,
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
    unsubscribe();
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

  void setValueMap(DataChunk pChunkData) {
    if (!lastCallbackIntentional && !pChunkData.update) {
      _valueMap.clear();
    }

    isAllFetched = pChunkData.isAllFetched;

    int indexOfKeyColumn = pChunkData.columnDefinitions
        .indexWhere((element) => element.name == model.linkReference.referencedColumnNames[0]);
    int indexOfValueColumn =
        pChunkData.columnDefinitions.indexWhere((element) => element.name == model.displayReferencedColumnName);

    for (List<dynamic> dataRow in pChunkData.data.values) {
      dynamic key = dataRow[indexOfKeyColumn];
      dynamic value = dataRow[indexOfValueColumn];

      _valueMap[key] = value;
    }

    lastCallbackIntentional = false;

    setValueIntoController();
  }

  void subscribe() {
    if (model.displayReferencedColumnName != null) {
      lastCallbackIntentional = true;
      if (!isAllFetched) {
        uiService.registerDataSubscription(
          pDataSubscription: DataSubscription(
            id: id!,
            dataProvider: model.linkReference.dataProvider,
            from: 0,
            to: pageLoad * currentPage,
            onDataChunk: setValueMap,
          ),
        );
      }
    }
  }

  void unsubscribe() {
    uiService.disposeDataSubscription(pComponentId: id!, pDataProvider: model.linkReference.referencedDataBook);
  }

  void increaseValueMap() {
    currentPage++;
    subscribe();
  }

  void setValueIntoController() {
    if (_value == null) {
      textController.clear();
    } else {
      dynamic showValue = _value;

      if (model.displayReferencedColumnName != null) {
        showValue = _valueMap[_value];
      }

      if (showValue == null) {
        textController.clear();
        increaseValueMap();
      } else {
        if (showValue is! String) {
          showValue = showValue.toString();
        }
        textController.value = textController.value.copyWith(
          text: showValue,
          selection: TextSelection.collapsed(offset: showValue.characters.length),
          composing: null,
        );
      }
    }

    recalculateSizeCallback?.call(false);
  }

  //TODO: implement this method
  @override
  String formatValue(Object pValue) {
    return pValue.toString();
  }
}
