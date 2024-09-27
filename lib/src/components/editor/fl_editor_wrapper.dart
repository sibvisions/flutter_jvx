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
import 'dart:math';

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
import '../../model/layout/layout_position.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../service/command/i_command_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'cell_editor/date/fl_date_cell_editor.dart';
import 'cell_editor/fl_dummy_cell_editor.dart';
import 'cell_editor/i_cell_editor.dart';
import 'cell_editor/linked/fl_linked_cell_editor.dart';

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

  /// The currently used cell editor.
  ICellEditor cellEditor = FlDummyCellEditor();

  /// Last value;
  dynamic _currentValue;

  FlEditorWrapperState() : super();

  /// The onChangeTimer that is used to send the value to the server if saving [savingImmediate] is true.
  Timer? onChangeTimer;

  DalMetaData? metaData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    // Exception where we have to do stuff before we init the sate.
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.
    recreateCellEditor(false);
    model.applyComponentInformation(cellEditor.createWidgetModel());

    super.initState();

    //also retrieves data
    subscribe();
  }

  @override
  modelUpdated() {
    // If a change of cell editors has occurred.
    if (model.changedCellEditor) {
      unsubscribe();

      recreateCellEditor();

      model.applyComponentInformation(cellEditor.createWidgetModel());
    }

    super.modelUpdated();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: cellEditor.createWidget(model.json));
  }

  @override
  void dispose() {
    cellEditor.dispose();
    super.dispose();
  }

  @override
  Size calculateSize(BuildContext context) {
    double? sizeWidth = cellEditor.getEditorWidth(model.json);
    if (sizeWidth != null) {
      sizeWidth += cellEditor.getContentPadding(model.json);
    }

    double? sizeHeight = cellEditor.getEditorHeight(model.json);

    if (sizeWidth == null || sizeHeight == null) {
      Size calculatedSize = super.calculateSize(context);
      sizeWidth ??= calculatedSize.width;
      sizeHeight ??= calculatedSize.height;
    }

    return Size(sizeWidth, sizeHeight);
  }

  @override
  LayoutData calculateConstrainedSize(LayoutPosition? calcPosition) {
    double calcWidth = layoutData.calculatedSize!.width;
    double calcHeight = layoutData.calculatedSize!.height;

    LayoutPosition constraintPos = calcPosition ?? layoutData.layoutPosition!;

    double positionWidth = constraintPos.width;
    double positionHeight = constraintPos.height;

    // Constraint by width
    if (layoutData.widthConstrains[positionWidth] == null && calcWidth > positionWidth) {
      double newHeight = cellEditor.getEditorHeight(model.json) ??
          (lastContext!.findRenderObject() as RenderBox).getMaxIntrinsicHeight(max(0.0, positionWidth)).ceilToDouble();

      layoutData.widthConstrains[positionWidth] = newHeight;
    }

    // Constraint by height
    if (layoutData.heightConstrains[positionHeight] == null && calcHeight > positionHeight) {
      double? newWidth = cellEditor.getEditorWidth(model.json) ??
          (lastContext!.findRenderObject() as RenderBox).getMaxIntrinsicWidth(max(0.0, positionHeight)).ceilToDouble();

      layoutData.heightConstrains[positionHeight] = newWidth;
    }

    var sentData = LayoutData.from(layoutData);
    sentData.layoutPosition = constraintPos;
    return sentData;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the service and registers the set value call back.
  void subscribe([bool pImmediatelyRetrieveData = true]) {
    if (model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          onSelectedRecord: setValue,
          onMetaData: receiveMetaData,
          dataColumns: isLinkedEditor() ? null : [model.columnName],
        ),
          pImmediatelyRetrieveData: pImmediatelyRetrieveData
      );
    }
  }

  bool isLinkedEditor() {
    return model.json[ApiObjectProperty.cellEditor][ApiObjectProperty.className] ==
        FlCellEditorClassname.LINKED_CELL_EDITOR;
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
    }
    setState(() {});
  }

  void _onValueChanged(dynamic pValue) {
    IUiService()
        .saveAllEditors(
      pId: model.id,
      pReason: "Value of ${model.id} set to $pValue",
    )
        .then((success) {
      if (!success) {
        return false;
      }

      ICommandService().sendCommand(_sendValueToServer(pValue));
    });

    setState(() {});
  }

  void setValue(DataRecord? pDataRecord) {
    var oldValue = _currentValue;
    if (pDataRecord != null && pDataRecord.values.isNotEmpty && pDataRecord.columnDefinitions.isNotEmpty) {
      _currentValue = pDataRecord.values[pDataRecord.columnDefinitions.indexWhere((e) => e.name == model.columnName)];
    } else {
      _currentValue = null;
    }

    if (isLinkedEditor()) {
      cellEditor.setValue((_currentValue, pDataRecord?.values));
      setState(() {});
    } else  if (oldValue != _currentValue) {
      cellEditor.setValue(_currentValue);

      setState(() {});
    }
  }

  void receiveMetaData(DalMetaData pMetaData) {
    metaData = pMetaData;

    cellEditor.setColumnDefinition(metaData!.columnDefinition(model.columnName));

    setState(() {});
  }

  /// Sets the state of the widget and sends a set value command.
  Future<void> onEndEditing(dynamic pValue) async {
    onChangeTimer?.cancel();
    if (_isSameValue(pValue) || !model.isEnabled) {
      setState(() {});
      return;
    }

    await IUiService()
        .saveAllEditors(
      pId: model.id,
      pReason: "Value of ${model.id} set to $pValue",
    )
        .then((success) {
      if (!success) {
        return false;
      }

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
      return ICommandService().sendCommands(commands);
    });

    setState(() {});
  }

  SetValuesCommand _sendValueToServer(pValue) {
    if (pValue is HashMap<String, dynamic>) {
      FlutterUI.logUI.d("Values of ${model.id} set to $pValue");
      return SetValuesCommand(
        editorColumnName: model.columnName,
        dataProvider: model.dataProvider,
        columnNames: pValue.keys.toList(),
        values: pValue.values.toList(),
        reason: "Value of ${model.id} set to $pValue",
      );
    } else {
      FlutterUI.logUI.d("Value of ${model.id} set to $pValue");
      return SetValuesCommand(
        dataProvider: model.dataProvider,
        editorColumnName: model.columnName,
        columnNames: [model.columnName],
        values: [pValue],
        reason: "Value of ${model.id} set to $pValue",
      );
    }
  }

  void recalculateSize([bool pRecalculate = true]) {
    if (pRecalculate) {
      sentLayoutData = false;
    }

    setState(() {});
  }

  /// Recreates the cell editor.
  void recreateCellEditor([bool pSubscribe = true]) {
    cellEditor.dispose();

    Map<String, dynamic> jsonCellEditor = Map.of(model.json[ApiObjectProperty.cellEditor]);
    cellEditor = ICellEditor.getCellEditor(
      pName: model.name,
      pCellEditorJson: jsonCellEditor,
      columnName: model.columnName,
      dataProvider: model.dataProvider,
      onChange: onChange,
      onEndEditing: onEndEditing,
      onFocusChanged: _onFocusChange,
      pRecalculateCallback: recalculateSize,
      isInTable: false,
    );

    cellEditor.model.styles.addAll(model.styles);

    if (pSubscribe) {
      subscribe();
    }
  }

  @override
  Future<BaseCommand?> createSaveCommand(String pReason) async {
    if (!model.isEnabled || metaData == null || !metaData!.updateEnabled) {
      return null;
    }

    dynamic value = await cellEditor.getValue();
    // cellEditor.formatValue(pValue)
    if (_isSameValue(value)) {
      return null;
    }

    return SetValuesCommand(
      dataProvider: model.dataProvider,
      editorColumnName: model.columnName,
      columnNames: [model.columnName],
      values: [value],
      reason: "$pReason; Value of ${model.id} set to $value",
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
