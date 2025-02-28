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

import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../components.dart';
import '../../../../model/command/api/filter_command.dart';
import '../../../../model/command/api/select_record_command.dart';
import '../../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/reference_definition.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/data/i_data_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/parse_util.dart';
import '../i_cell_editor.dart';

class FlLinkedCellEditor extends IFocusableCellEditor<FlLinkedEditorModel, FlLinkedCellEditorModel, dynamic> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (dynamic, List<dynamic>?)? _record;

  dynamic get _value => _record?.$1;

  TextEditingController textController = TextEditingController();

  bool isOpen = false;

  FlLinkedEditorModel? lastWidgetModel;

  ReferencedCellEditor? referencedCellEditor;

  @override
  bool get allowedTableEdit => model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK;

  @override
  bool get tableDeleteIcon => !model.hideClearIcon && super.tableDeleteIcon;

  @override
  IconData? get tableEditIcon => FontAwesomeIcons.caretDown;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor({
    required super.cellEditorJson,
    required super.name,
    required super.dataProvider,
    required super.columnName,
    required super.columnDefinition,
    super.isInTable,
    super.focusChecker,
    required super.onValueChange,
    required super.onEndEditing,
    super.onFocusChanged,
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
    _record = pValue;

    _updateControllerValue();
  }

  @override
  FlLinkedEditorWidget createWidget(Map<String, dynamic>? pJson) {
    FlLinkedEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    return FlLinkedEditorWidget(
      model: widgetModel,
      endEditing: (_) => receiveNull(),
      valueChanged: onValueChange,
      textController: textController,
      focusNode: focusNode,
      hideClearIcon: model.hideClearIcon,
    );
  }

  @override
  createWidgetModel() => FlLinkedEditorModel();

  @override
  void dispose() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: dataProvider);
    referencedCellEditor?.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Future<dynamic> getValue() async {
    return _value;
  }

  @override
  String formatValue(Object? pValue) {
    Object? showValue = pValue;
    if (showValue == null) {
      return "";
    }

    if (model.displayConcatMask != null || model.displayReferencedColumnName != null) {
      ReferenceDefinition linkReference = effectiveLinkReference;

      int linkRefColumnIndex = linkReference.columnNames.indexOf(columnName);
      if (linkRefColumnIndex == -1) {
        // Invalid definition by the developer, Swing throws InvalidArgumentException.
        // Possible solution: just return value and ignore concatMask and others.
        linkRefColumnIndex = 0;
      }

      if (model.additionalCondition != null || model.searchColumnMapping != null) {
        var dataBook = IDataService().getDataBook(dataProvider);
        if (dataBook != null && _record?.$2 != null) {
          Map<String, dynamic> displayKeyMap = model.createDisplayMapKey(
            dataBook.metaData!.columnDefinitions,
            _record!.$2!,
            linkReference,
            columnName,
            dataProvider: dataProvider,
          );
          var displayKey = jsonEncode(displayKeyMap);

          if (linkReference.dataToDisplay.containsKey(displayKey)) {
            return linkReference.dataToDisplay[displayKey] ?? showValue.toString();
          }
        }
      }

      var fallbackDataKey = jsonEncode(
          model.createFallbackDisplayKey(linkReference.referencedColumnNames[linkRefColumnIndex], showValue));

      if (linkReference.dataToDisplay.containsKey(fallbackDataKey)) {
        return linkReference.dataToDisplay[fallbackDataKey] ?? showValue.toString();
      }
    }

    return showValue.toString();
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
  double getEditorHeight(Map<String, dynamic>? pJson) {
    return FlTextFieldWidget.TEXT_FIELD_HEIGHT;
  }

  @override
  void handleFocusChanged(bool pHasFocus) {
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
          .sendCommand(
        FilterCommand.byValue(
          dataProvider: model.linkReference.referencedDataBook,
          editorComponentId: (lastWidgetModel?.name.isNotEmpty ?? false) ? lastWidgetModel!.name : name,
          columnNames: [columnName],
          // Same as React
          value: "",
          reason: "Opened the linked cell picker",
        ),
      )
          .then((success) {
        if (!success) {
          return null;
        }
        return IUiService()
            .openDialog(
          pBuilder: (_) => FlLinkedCellPicker(
            linkedCellEditor: this,
            model: model,
            name: name!,
            editorColumnDefinition: columnDefinition,
          ),
          pIsDismissible: true,
        )
            .then((value) {
          if (value != null) {
            if (value == FlLinkedCellPicker.NULL_OBJECT) {
              receiveNull();
            } else {
              onEndEditing(value);
            }
          }
        });
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
          onDataToDisplayMapChanged: _updateControllerValue,
        ),
      );

      // Checks if the column of the metadata has a link reference
      // If not, then we have to create the referenced cell editor ourselves
      if (model.linkReference == effectiveLinkReference) {
        referencedCellEditor = IDataService().createReferencedCellEditors(model, dataProvider, columnName);
      }
    }
  }

  void _updateControllerValue() {
    if (_value == null) {
      textController.clear();
    } else {
      dynamic showValue = formatValue(_value!);

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
  }

  void receiveNull() {
    List<String> columnsToSend = [columnName];
    if (model.linkReference.columnNames.isNotEmpty) {
      columnsToSend = model.linkReference.columnNames;
    }

    if (model.additionalClearColumnNames?.isNotEmpty == true) {
      columnsToSend.addAll(model.additionalClearColumnNames!);
    }

    if (model.clearColumnNames?.isNotEmpty == true) {
      columnsToSend.addAll(model.clearColumnNames!);
    }

    Map<String, dynamic> dataMap = HashMap<String, dynamic>();

    for (String columnName in columnsToSend) {
      dataMap[columnName] = null;
    }

    ICommandService()
        .sendCommand(SelectRecordCommand.deselect(
      dataProvider: model.linkReference.referencedDataBook,
      reason: "Tapped",
    ))
        .then(
      (success) {
        if (success) {
          onEndEditing(dataMap);
        }
      },
    );
  }

  ReferenceDefinition get effectiveLinkReference {
    ColumnDefinition? colDef = IDataService().getMetaData(dataProvider)?.columnDefinitions.byName(columnName);

    return (colDef?.cellEditorModel is FlLinkedCellEditorModel)
        ? (colDef!.cellEditorModel as FlLinkedCellEditorModel).linkReference
        : model.linkReference;
  }
}
