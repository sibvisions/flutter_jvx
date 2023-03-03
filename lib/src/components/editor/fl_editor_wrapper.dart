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

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/ui/i_ui_service.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'cell_editor/date/fl_date_cell_editor.dart';
import 'cell_editor/fl_choice_cell_editor.dart';
import 'cell_editor/fl_dummy_cell_editor.dart';
import 'cell_editor/fl_image_cell_editor.dart';
import 'cell_editor/fl_text_cell_editor.dart';
import 'cell_editor/i_cell_editor.dart';
import 'cell_editor/linked/fl_linked_cell_editor.dart';
import 'text_area/fl_text_area_widget.dart';

/// The [FlEditorWrapper] wraps various cell editors and makes them usable as single wrapped widgets.
/// It serves as the layouting wrapper of various non layouting widgets.
class FlEditorWrapper<T extends FlEditorModel> extends BaseCompWrapperWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlEditorWrapper({super.key, required super.model});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlEditorWrapperState createState() => FlEditorWrapperState();
}

class FlEditorWrapperState<T extends FlEditorModel> extends BaseCompWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If anything has a focus, the set value event must be added as a listener.
  /// As to send it last.
  FocusNode? currentObjectFocused;

  /// The old cell editor which might have to be disposed of.
  ICellEditor? oldCellEditor;

  /// The currently used cell editor.
  ICellEditor cellEditor = FlDummyCellEditor();

  /// Last value;
  dynamic _currentValue;

  FlEditorWrapperState() : super();

  /// The onChangeTimer that is used to send the value to the server if saving [savingImmediate] is true.
  Timer? onChangeTimer;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    // Exception where we have to do stuff before we init the sate.
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.
    model = widget.model;

    recreateCellEditor(false);

    model.applyComponentInformation(cellEditor.createWidgetModel());

    super.initState();

    subscribe();
  }

  @override
  modelUpdated() {
    // If a change of cell editors has occured.
    if (model.changedCellEditor) {
      unsubscribe();

      recreateCellEditor();

      logCellEditor("RECEIVE_NEW_MODEL");

      model.applyComponentInformation(cellEditor.createWidgetModel());
    }

    super.modelUpdated();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    logCellEditor("BUILD");

    return getPositioned(child: cellEditor.createWidget(model.json));
  }

  @override
  void postFrameCallback(BuildContext context) {
    super.postFrameCallback(context);

    // Dispose of the old one after the build to clean up memory.
    oldCellEditor?.dispose();
    oldCellEditor = null;
  }

  @override
  void dispose() {
    cellEditor.dispose();
    super.dispose();
  }

  @override
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    Size? newCalcSize;

    double? width = cellEditor.getEditorWidth(model.json);
    if (width != null) {
      width += cellEditor.getContentPadding(model.json);

      if (cellEditor is FlChoiceCellEditor || cellEditor is FlImageCellEditor) {
        newCalcSize = Size.square(width);
      } else if (cellEditor is FlTextCellEditor &&
          (cellEditor.model.contentType == FlTextCellEditor.TEXT_PLAIN_WRAPPEDMULTILINE ||
              cellEditor.model.contentType == FlTextCellEditor.TEXT_PLAIN_MULTILINE)) {
        FlTextAreaModel textModel = cellEditor.createWidgetModel() as FlTextAreaModel;

        textModel.applyFromJson(model.json);

        newCalcSize = Size(
          width,
          FlTextAreaWidget.calculateTextAreaHight(pLayoutData.calculatedSize!, textModel).height,
        );
      } else {
        newCalcSize = Size(
          width,
          layoutData.calculatedSize!.height,
        );
      }
    }

    if (newCalcSize != null) {
      pLayoutData = pLayoutData.clone();
      pLayoutData.calculatedSize = newCalcSize;

      pLayoutData.widthConstrains.forEach((key, value) {
        pLayoutData.widthConstrains[key] = newCalcSize!.height;
      });
      pLayoutData.heightConstrains.forEach((key, value) {
        pLayoutData.heightConstrains[key] = newCalcSize!.width;
      });
    }
    super.sendCalcSize(pLayoutData: pLayoutData, pReason: pReason);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the service and registers the set value call back.
  void subscribe() {
    if (model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          onSelectedRecord: setValue,
          onMetaData: receiveMetaData,
          dataColumns: [model.columnName],
        ),
      );
    }
  }

  /// Unsubscribes the callback of the cell editor from value changes.
  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  /// Sets the state after value change to rebuild the widget and reflect the value change.
  void onChange(dynamic pValue) {
    if (model.savingImmediate) {
      onChangeTimer?.cancel();
      onChangeTimer = Timer(const Duration(milliseconds: 300), () => _onValueChanged(pValue));

      // Textfield wont update immediately, so we need to force it to update.
      setState(() {});
    }
  }

  void _onValueChanged(dynamic pValue) {
    IUiService()
        .saveAllEditors(
          pId: model.id,
          pFunction: () async {
            return [_sendValueToServer(pValue)];
          },
          pReason: "Value of ${model.id} set to $pValue",
        )
        .catchError(IUiService().handleAsyncError);

    setState(() {});
  }

  void setValue(DataRecord? pDataRecord) {
    var oldValue = _currentValue;
    if (pDataRecord != null) {
      _currentValue = pDataRecord.values[pDataRecord.columnDefinitions.indexWhere((e) => e.name == model.columnName)];
    } else {
      _currentValue = null;
    }
    if (oldValue != _currentValue) {
      cellEditor.setValue(_currentValue);
      setState(() {});
    }
  }

  void receiveMetaData(DalMetaData pMetaData) {
    ColumnDefinition? newColDef =
        pMetaData.columnDefinitions.firstWhereOrNull((element) => element.name == model.columnName);
    cellEditor.setColumnDefinition(newColDef);
    setState(() {});
  }

  /// Sets the state of the widget and sends a set value command.
  void onEndEditing(dynamic pValue) {
    onChangeTimer?.cancel();
    if (_isSameValue(pValue) || !model.isEnabled) {
      cellEditor.setValue(_currentValue);
      setState(() {});
      return;
    }

    IUiService()
        .saveAllEditors(
          pId: model.id,
          pFunction: () async {
            List<BaseCommand> commands = [];

            var oldFocus = IUiService().getFocus();
            commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"));

            commands.add(_sendValueToServer(pValue));

            if (cellEditor is FlDateCellEditor || cellEditor is FlLinkedCellEditor) {
              SetFocusCommand(componentId: model.id, focus: false, reason: "Value edit Focus");
            }
            if (oldFocus != null) {
              commands.add(SetFocusCommand(componentId: oldFocus.id, focus: true, reason: "Value edit Focus"));
            } else {
              commands.add(SetFocusCommand(componentId: model.id, focus: false, reason: "Value edit Focus"));
            }
            return commands;
          },
          pReason: "Value of ${model.id} set to $pValue",
        )
        .catchError(IUiService().handleAsyncError);

    setState(() {});
  }

  SetValuesCommand _sendValueToServer(pValue) {
    if (pValue is HashMap<String, dynamic>) {
      FlutterUI.logUI.d("Values of ${model.id} set to $pValue");
      return SetValuesCommand(
        componentId: model.id,
        editorColumnName: model.columnName,
        dataProvider: model.dataProvider,
        columnNames: pValue.keys.toList(),
        values: pValue.values.toList(),
        reason: "Value of ${model.id} set to $pValue",
      );
    } else {
      FlutterUI.logUI.d("Value of ${model.id} set to $pValue");
      return SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        editorColumnName: model.columnName,
        columnNames: [model.columnName],
        values: [pValue],
        reason: "Value of ${model.id} set to $pValue",
      );
    }
  }

  void recalculateSize([bool pRecalulcate = true]) {
    if (pRecalulcate) {
      sentCalcSize = false;
    }

    setState(() {});
  }

  /// Recreates the cell editor.
  void recreateCellEditor([bool pSubscribe = true]) {
    oldCellEditor = cellEditor;

    var jsonCellEditor = Map<String, dynamic>.from(model.json[ApiObjectProperty.cellEditor]);
    cellEditor = ICellEditor.getCellEditor(
      pName: model.name,
      pCellEditorJson: jsonCellEditor,
      onChange: onChange,
      onEndEditing: onEndEditing,
      onFocusChanged: _onFocusChange,
      pRecalculateSizeCallback: recalculateSize,
      isInTable: false,
    );

    if (pSubscribe) {
      subscribe();
    }
  }

  /// Logs the cell editor for debug purposes.
  void logCellEditor(String pPhase) {
    FlutterUI.logUI.d("""
----- $pPhase -----
Old cell editor hashcode: ${oldCellEditor?.hashCode}
New cell editor hashcode: ${cellEditor.hashCode}
----- $pPhase -----""", null, StackTrace.current);
  }

  @override
  BaseCommand? createSaveCommand() {
    dynamic value = cellEditor.getValue();
    // cellEditor.formatValue(pValue)
    if (_isSameValue(value)) {
      return null;
    }
    return SetValuesCommand(
      componentId: model.id,
      dataProvider: model.dataProvider,
      editorColumnName: model.columnName,
      columnNames: [model.columnName],
      values: [value],
      reason: "Value of ${model.id} set to $value",
    );
  }

  bool _isSameValue(dynamic value) {
    return cellEditor.formatValue(value) == cellEditor.formatValue(_currentValue);
  }

  void _onFocusChange(bool pFocus) {
    if (pFocus) {
      focus();
    } else {
      unfocus();
    }
  }
}
