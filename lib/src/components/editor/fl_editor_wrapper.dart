import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/command/api/set_values_command.dart';
import 'package:flutter_client/src/model/component/dummy/fl_dummy_cell_editor.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/component/editor/fl_editor_model.dart';
import '../../model/component/i_cell_editor.dart';

class FlEditorWrapper extends BaseCompWrapperWidget<FlEditorModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlEditorWrapper({Key? key, required FlEditorModel model}) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlEditorWrapperState createState() => FlEditorWrapperState();
}

class FlEditorWrapperState<T extends FlEditorModel> extends BaseCompWrapperState<T> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditor? oldCellEditor;

  ICellEditor cellEditor = FlDummyCellEditor(pCellEditorJson: {});

  @override
  void initState() {
    // Only exception where we actually have to do stuff BEFORE we init the sate...
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.
    recreateCellEditor(widget.model as T);

    (widget.model as FlEditorModel).applyComponentInformation(cellEditor.getWidget().model);

    subscribe(widget.model as T);

    super.initState();
  }

  @override
  receiveNewModel({required T newModel}) {
    if (newModel.changedCellEditor) {
      unsubscribe();

      oldCellEditor = cellEditor;

      recreateCellEditor(newModel);

      logCellEditor("RECEIVE_NEW_MODEL");

      (widget.model as FlEditorModel).applyComponentInformation((cellEditor.getWidget()).model);
    }

    super.receiveNewModel(newModel: newModel);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    FlStatelessWidget editorWidget = cellEditor.getWidget();
    editorWidget.model.applyFromJson(model.json);
    editorWidget.model.applyCellEditorOverrides(model.json);

    logCellEditor("BUILD");

    return getPositioned(child: editorWidget);
  }

  @override
  void postFrameCallback(BuildContext context) {
    super.postFrameCallback(context);

    oldCellEditor?.dispose();
    oldCellEditor = null;
  }

  void subscribe(T pModel) {
    uiService.registerAsDataComponent(
        pDataProvider: pModel.dataRow,
        pCallback: cellEditor.setValue,
        pComponentId: pModel.id,
        pColumnName: pModel.columnName);
  }

  void unsubscribe() {
    uiService.unRegisterDataComponent(pComponentId: model.id, pDataProvider: model.dataRow);
  }

  void onChange(dynamic pValue) {
    setState(() {
      cellEditor.setValue(pValue);
    });
  }

  void onEndEditing(dynamic pValue) {
    setState(() {
      cellEditor.setValue(pValue);
    });

    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "editing ended");
    LOGGER.logI(pType: LOG_TYPE.DATA, pMessage: "Value of ${model.id} set to $pValue");
    uiService.sendCommand(SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataRow,
        columnNames: [model.columnName],
        values: [cellEditor.getValue()],
        reason: "Value of ${model.id} set to $pValue"));
  }

  @override
  void dispose() {
    cellEditor.dispose();
    super.dispose();
  }

  void recreateCellEditor(T pModel) {
    var jsonCellEditor = pModel.json[ApiObjectProperty.cellEditor];
    if (jsonCellEditor != null) {
      cellEditor =
          ICellEditor.getCellEditor(pCellEditorJson: jsonCellEditor, onChange: onChange, onEndEditing: onEndEditing);
      subscribe(pModel);
    }
  }

  void logCellEditor(String pPhase) {
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: StackTrace.current.toString());
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "----- $pPhase -----");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "Old cell editor hashcode: ${oldCellEditor?.hashCode}");
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "New cell editor hashcode: ${cellEditor.hashCode}");
    LOGGER.logD(
        pType: LOG_TYPE.UI,
        pMessage: "Old cell editor widget hashcode: " + (oldCellEditor?.getWidget().hashCode.toString() ?? ""));
    LOGGER.logD(
        pType: LOG_TYPE.UI, pMessage: "New cell editor widget hashcode: " + cellEditor.getWidget().hashCode.toString());
    LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "----- $pPhase -----");
  }
}
