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

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../model/command/api/filter_command.dart';
import '../../../../model/command/api/select_record_command.dart';
import '../../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/data/i_data_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/parse_util.dart';
import '../i_cell_editor.dart';
import 'fl_linked_cell_picker.dart';
import 'fl_linked_editor_widget.dart';

class FlLinkedCellEditor
    extends IFocusableCellEditor<FlLinkedEditorModel, FlLinkedEditorWidget, FlLinkedCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const int PAGE_LOAD = 50;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final HashMap<dynamic, dynamic> _valueMap = HashMap();

  int currentPage = 1;

  bool lastCallbackIntentional = true;

  bool isAllFetched = false;

  dynamic _value;

  TextEditingController textController = TextEditingController();

  RecalculateCallback? recalculateSizeCallback;

  bool isOpen = false;

  FlLinkedEditorModel? lastWidgetModel;

  @override
  bool get allowedInTable => false;

  @override
  bool get allowedTableEdit => model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK;

  @override
  bool get tableDeleteIcon => true;

  @override
  IconData? get tableEditIcon => FontAwesomeIcons.caretDown;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor({
    required super.name,
    required super.columnDefinition,
    required super.cellEditorJson,
    required super.onValueChange,
    required super.onEndEditing,
    required super.columnName,
    required super.dataProvider,
    super.onFocusChanged,
    super.isInTable,
    this.recalculateSizeCallback,
  }) : super(
          model: FlLinkedCellEditorModel(),
        ) {
    focusNode.skipTraversal = true;

    _subscribe();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _value = pValue;

    _setValueIntoController();
  }

  @override
  createWidget(Map<String, dynamic>? pJson) {
    FlLinkedEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    return FlLinkedEditorWidget(
      model: widgetModel,
      endEditing: receiveNull,
      valueChanged: onValueChange,
      textController: textController,
      focusNode: focusNode,
      hideClearIcon: !allowedTableEdit && isInTable,
    );
  }

  @override
  createWidgetModel() => FlLinkedEditorModel();

  @override
  void dispose() {
    _unsubscribe();
    textController.dispose();
    super.dispose();
  }

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson) {
    return createWidget(pJson).extraWidthPaddings();
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson) {
    FlLinkedEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    double colWidth = ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle());

    if (isInTable) {
      return colWidth * widgetModel.columns / 2;
    }
    return colWidth * widgetModel.columns;
  }

  @override
  bool firesFocusCallback() {
    return false;
  }

  @override
  void focusChanged(bool pHasFocus) {
    if (focusNode.hasPrimaryFocus && lastWidgetModel != null) {
      if (!lastWidgetModel!.isFocusable) {
        focusNode.unfocus();
      } else if (lastWidgetModel!.isEditable && lastWidgetModel!.isEnabled) {
        openLinkedCellPicker();

        focusNode.unfocus();
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void>? openLinkedCellPicker() {
    if (!isOpen) {
      if (lastWidgetModel != null && lastWidgetModel!.isFocusable) {
        onFocusChanged?.call(true);
      }
      isOpen = true;

      return ICommandService()
          .sendCommand(FilterCommand(
              editorId: name!,
              value: "",
              dataProvider: model.linkReference.referencedDataprovider,
              reason: "Opened the linked cell picker"))
          .then((value) {
        return IUiService().openDialog(
            pBuilder: (_) => FlLinkedCellPicker(
                  model: model,
                  name: name!,
                  editorColumnDefinition: columnDefinition,
                ),
            pIsDismissible: true);
      }).then((value) {
        if (value != null) {
          if (value == FlLinkedCellPicker.NULL_OBJECT) {
            receiveNull(null);
          } else {
            onEndEditing(value);
          }
        }
      }).catchError((error, stacktrace) {
        IUiService().handleAsyncError(error, stacktrace);
      }).whenComplete(() {
        isOpen = false;
        // The "onEndEditing" of the FlEditorWrapper handles the focus for the linked cell picker and date cell editor.
      });
    }
    return null;
  }

  void _setValueMap(DataChunk pChunkData) {
    if (!lastCallbackIntentional) {
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

    _setValueIntoController();
  }

  void _subscribe() {
    if (model.displayReferencedColumnName != null) {
      lastCallbackIntentional = true;
      if (!isAllFetched) {
        IUiService().registerDataSubscription(
          pDataSubscription: DataSubscription(
            subbedObj: this,
            dataProvider: model.linkReference.referencedDataprovider,
            from: 0,
            to: PAGE_LOAD * currentPage,
            onDataChunk: _setValueMap,
            onReload: _onDataProviderReload,
          ),
        );
      }
    }
  }

  int _onDataProviderReload(int pSelectedRow) {
    if (pSelectedRow >= 0) {
      currentPage = ((pSelectedRow + 1) / PAGE_LOAD).ceil();
    } else {
      currentPage = 1;
    }
    return PAGE_LOAD * currentPage;
  }

  void _unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.linkReference.referencedDataprovider);
  }

  void _increaseValueMap() {
    currentPage++;
    _subscribe();
  }

  void _setValueIntoController() {
    if (_value == null) {
      textController.clear();
    } else {
      dynamic showValue = _value;

      if (model.displayReferencedColumnName != null) {
        showValue = _valueMap[showValue];
      }

      if (showValue == null) {
        textController.clear();
        _increaseValueMap();
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

  dynamic receiveNull(dynamic pValue) {
    return ICommandService()
        .sendCommand(
      SelectRecordCommand(
        dataProvider: model.linkReference.referencedDataprovider,
        selectedRecord: -1,
        reason: "Tapped",
        filter: null,
      ),
    )
        .then((value) {
      if (model.linkReference.columnNames.isEmpty) {
        onEndEditing(null);
      } else {
        HashMap<String, dynamic> dataMap = HashMap<String, dynamic>();

        for (int i = 0; i < model.linkReference.columnNames.length; i++) {
          String columnName = model.linkReference.columnNames[i];

          dataMap[columnName] = null;
        }

        onEndEditing(dataMap);
      }
    }).catchError(IUiService().handleAsyncError);
  }
}
