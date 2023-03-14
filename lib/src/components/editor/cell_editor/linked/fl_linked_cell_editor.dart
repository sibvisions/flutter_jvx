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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/link_reference.dart';
import '../../../../model/component/fl_component_model.dart';
import '../i_cell_editor.dart';

class FlLinkedCellEditor
    extends IFocusableCellEditor<FlLinkedEditorModel, FlLinkedEditorWidget, FlLinkedCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: dataProvider);
    textController.dispose();
    super.dispose();
  }

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  String formatValue(dynamic pValue) {
    dynamic showValue = pValue;

    if (model.displayConcatMask != null || model.displayReferencedColumnName != null) {
      LinkReference linkReference = correctLinkReference;
      int colIndex = linkReference.columnNames.indexOf(columnName);

      if (colIndex == -1) {
        colIndex = 0;
      }

      String valueColumnName = linkReference.referencedColumnNames[colIndex];

      Map<String, dynamic> valueKeyMap = {valueColumnName: pValue};
      var valueKey = jsonEncode(valueKeyMap);

      showValue = linkReference.dataToDisplay[valueKey] ?? showValue;
    }

    return showValue?.toString() ?? "";
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

  void _subscribe() {
    if ((model.displayReferencedColumnName != null || model.displayConcatMask != null) && dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: dataProvider,
          from: 0,
          to: -1,
          onDataToDisplayMapChanged: _onDataToDisplayMapChanged,
        ),
      );

      if (IDataService()
          .databookNeedsFetch(pDataProvider: model.linkReference.referencedDataprovider, pFrom: 0, pTo: -1)) {
        IUiService().sendCommand(
          FetchCommand(
            fromRow: 0,
            rowCount: -1,
            dataProvider: model.linkReference.referencedDataprovider,
            reason: "Linked cell editor fetches referenced dataprovider",
          ),
        );
      }
    }
  }

  void _setValueIntoController([bool recalculateSize = false]) {
    if (_value == null) {
      textController.clear();
    } else {
      dynamic showValue = formatValue(_value);

      if (showValue == null) {
        textController.clear();
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

    recalculateSizeCallback?.call(recalculateSize);
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

  void _onDataToDisplayMapChanged() {
    _setValueIntoController(true);
  }

  LinkReference get correctLinkReference {
    ColumnDefinition? colDef = IDataService()
        .getDataBook(dataProvider)
        ?.metaData
        .columnDefinitions
        .firstWhereOrNull((element) => element.name == columnName);

    return (colDef?.cellEditorModel is FlLinkedCellEditorModel)
        ? (colDef!.cellEditorModel as FlLinkedCellEditorModel).linkReference
        : model.linkReference;
  }
}
