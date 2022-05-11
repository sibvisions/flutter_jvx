import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/util/parse_util.dart';

import '../../../util/logging/flutter_logger.dart';
import '../../model/api/api_object_property.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/component/editor/fl_editor_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/layout/layout_data.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import 'cell_editor/fl_choice_cell_editor.dart';
import 'cell_editor/fl_dummy_cell_editor.dart';
import 'cell_editor/fl_image_cell_editor.dart';
import 'cell_editor/fl_text_cell_editor.dart';
import 'cell_editor/i_cell_editor.dart';

/// The [FlEditorWrapper] wraps various cell editors and makes them usable as single wrapped widgets.
/// It serves as the layouting wrapper of various non layouting widgets.
class FlEditorWrapper<T extends FlEditorModel> extends BaseCompWrapperWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlEditorWrapper({Key? key, required String id}) : super(key: key, id: id);

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

  /// The value to send to the server on sendValue.
  dynamic _toSendValue;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    // Exception where we have to do stuff before we init the sate.
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.
    recreateCellEditor(widget.model as T);

    (widget.model as FlEditorModel).applyComponentInformation(cellEditor.getWidgetModel());

    subscribe(widget.model as T);

    super.initState();
  }

  @override
  receiveNewModel({required T newModel}) {
    // If a change of cell editors has occured.
    if (newModel.changedCellEditor) {
      unsubscribe();

      recreateCellEditor(newModel);

      logCellEditor("RECEIVE_NEW_MODEL");

      newModel.applyComponentInformation(cellEditor.getWidgetModel());
    }

    super.receiveNewModel(newModel: newModel);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    // Celleditors always return a fresh new widget.
    // We must apply the universal editor components onto the widget.
    FlStatelessWidget editorWidget = cellEditor.getWidget(context);
    editorWidget.model.applyFromJson(model.json);
    // Some parts of a json have to take priority.
    // As they override the properties.
    editorWidget.model.applyCellEditorOverrides(model.json);

    logCellEditor("BUILD");

    return getPositioned(child: editorWidget);
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
    if (cellEditor is FlChoiceCellEditor) {
      FlChoiceCellEditor imageCellEditor = cellEditor as FlChoiceCellEditor;

      newCalcSize = imageCellEditor.imageSize;
    } else if (cellEditor is FlImageCellEditor) {
      FlImageCellEditor imageCellEditor = cellEditor as FlImageCellEditor;

      newCalcSize = imageCellEditor.imageSize;
    } else if (cellEditor is FlTextCellEditor && pLayoutData.hasCalculatedSize) {
      FlTextCellEditor textCellEditor = cellEditor as FlTextCellEditor;

      double averageColumnWidth = ParseUtil.getTextWidth(text: "w", style: model.getTextStyle());

      newCalcSize =
          Size(averageColumnWidth * textCellEditor.getWidgetModel().columns + 2, layoutData.calculatedSize!.height);
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
  void subscribe(T pModel) {
    uiService.registerAsDataComponent(
        pColumnDefinitionCallback: setColumnDefinition,
        pDataProvider: pModel.dataRow,
        pCallback: setValue,
        pComponentId: pModel.id,
        pColumnName: pModel.columnName);
  }

  /// Unsubscribes the callback of the cell editor from value changes.
  void unsubscribe() {
    uiService.unRegisterDataComponent(pComponentId: model.id, pDataProvider: model.dataRow);
  }

  /// Sets the state after value change to rebuild the widget and reflect the value change.
  void onChange(dynamic pValue) {
    setState(() {});
  }

  void setValue(dynamic pValue) {
    cellEditor.setValue(pValue);
  }

  void setColumnDefinition(ColumnDefinition? pColumnDefinition) {
    cellEditor.setColumnDefinition(pColumnDefinition);
  }

  /// Sets the state of the widget and sends a set value command.
  void onEndEditing(dynamic pValue) {
    _toSendValue = pValue;
    setState(() {});

    if (cellEditor.isActionCellEditor()) {
      currentObjectFocused = FocusManager.instance.primaryFocus;
      if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
        currentObjectFocused = null;
        sendValue();
      } else {
        LOGGER.logI(pType: LOG_TYPE.UI, pMessage: "Value will be set");
        currentObjectFocused!.addListener(sendValue);
        currentObjectFocused!.unfocus();
      }
    } else {
      sendValue();
    }
  }

  void recalculateSize() {
    sentCalcSize = false;

    setState(() {});
  }

  void sendValue() {
    if (_toSendValue is HashMap<String, dynamic>) {
      var map = _toSendValue as HashMap<String, dynamic>;

      LOGGER.logI(pType: LOG_TYPE.DATA, pMessage: "Values of ${model.id} set to $_toSendValue");
      uiService.sendCommand(SetValuesCommand(
          componentId: model.id,
          dataProvider: model.dataRow,
          columnNames: map.keys.toList(),
          values: map.values.toList(),
          reason: "Value of ${model.id} set to $_toSendValue"));
    } else {
      LOGGER.logI(pType: LOG_TYPE.DATA, pMessage: "Value of ${model.id} set to $_toSendValue");
      uiService.sendCommand(SetValuesCommand(
          componentId: model.id,
          dataProvider: model.dataRow,
          columnNames: [model.columnName],
          values: [_toSendValue],
          reason: "Value of ${model.id} set to $_toSendValue"));
    }

    if (currentObjectFocused != null) {
      currentObjectFocused!.removeListener(sendValue);
    }
  }

  /// Recreates the cell editor.
  void recreateCellEditor(T pModel) {
    oldCellEditor = cellEditor;

    var jsonCellEditor = pModel.json[ApiObjectProperty.cellEditor];
    if (jsonCellEditor != null) {
      cellEditor = ICellEditor.getCellEditor(
          pId: pModel.id,
          pName: pModel.name,
          pColumnName: pModel.columnName,
          pCellEditorJson: jsonCellEditor,
          onChange: onChange,
          onEndEditing: onEndEditing,
          pRecalculateSize: recalculateSize);
      subscribe(pModel);
    }
  }

  /// Logs the cell editor for debug purposes.
  void logCellEditor(String pPhase) {
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: StackTrace.current.toString());
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "----- $pPhase -----");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Old cell editor hashcode: ${oldCellEditor?.hashCode}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "New cell editor hashcode: ${cellEditor.hashCode}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "----- $pPhase -----");
  }
}
