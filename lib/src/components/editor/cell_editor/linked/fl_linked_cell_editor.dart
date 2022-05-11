import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/editor/cell_editor/linked/fl_linked_cell_picker.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_data.dart';

import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/data/chunk/chunk_subscription.dart';
import '../../../../model/data/column_definition.dart';
import '../i_cell_editor.dart';
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

  VoidCallback? imageLoadingCallback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor({
    required String id,
    required String name,
    required String columnName,
    required Map<String, dynamic> pCellEditorJson,
    required Function(dynamic) onChange,
    required Function(dynamic) onEndEditing,
    this.imageLoadingCallback,
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

    if (pValue == null) {
      textController.clear();
    } else {
      dynamic showValue = _valueMap[pValue];
      if (showValue != null && showValue is! String) {
        showValue = showValue.toString();
      }

      if (showValue == null) {
        textController.clear();
        currentPage++;
        subscribe();
      } else {
        showValue = showValue as String;
        textController.value = textController.value.copyWith(
          text: showValue,
          selection: TextSelection.collapsed(offset: showValue.characters.length),
          composing: null,
        );
      }
    }

    imageLoadingCallback?.call();
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
              name: name,
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

  void setValueMap(ChunkData pChunkData) {
    if (!lastCallbackIntentional) {
      _valueMap.clear();
    }

    isAllFetched = pChunkData.isAllFetched;

    int indexOfKeyColumn = pChunkData.columnDefinitions.indexWhere((element) => element.name == columnName);
    int indexOfValueColumn =
        pChunkData.columnDefinitions.indexWhere((element) => element.name == model.displayReferencedColumnName);

    for (int i = _valueMap.values.length; i < pChunkData.data.length; i++) {
      List<dynamic> dataRow = pChunkData.data[i]!;

      dynamic key = dataRow[indexOfKeyColumn];
      dynamic value = dataRow[indexOfValueColumn];

      _valueMap[key] = value;
    }

    lastCallbackIntentional = false;

    if (_valueMap[_value] == null) {
      currentPage++;
      subscribe();
    } else {
      dynamic showValue = _valueMap[_value];
      if (showValue is! String) {
        showValue = showValue.toString();
      }

      textController.value = textController.value.copyWith(
        text: showValue,
        selection: TextSelection.collapsed(offset: showValue.characters.length),
        composing: null,
      );

      imageLoadingCallback?.call();
    }
  }

  void subscribe() {
    if (model.displayReferencedColumnName != null) {
      lastCallbackIntentional = true;
      if (!isAllFetched) {
        uiService.registerDataChunk(
          chunkSubscription: ChunkSubscription(
            id: id,
            dataProvider: model.linkReference.referencedDataBook,
            from: 0,
            to: pageLoad * currentPage,
            callback: setValueMap,
          ),
        );
      }
    }
  }

  void unsubscribe() {
    uiService.unRegisterDataComponent(pComponentId: id, pDataProvider: model.linkReference.referencedDataBook);
  }
}
