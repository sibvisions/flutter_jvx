import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/dummy/fl_dummy_cell_editor.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../dummy/fl_dummy_widget.dart';
import '../../mixin/data_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/component/dummy/fl_dummy_model.dart';
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
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: cellEditor.getWidget());
  }

  @override
  receiveNewModel({required T newModel}) {
    unsubscribe();

    ICellEditor oldCellEditor = cellEditor;

    recreateCellEditor(newModel);

    (widget.model as FlEditorModel).applyComponentInformation((cellEditor.getWidget()).model);

    super.receiveNewModel(newModel: newModel);

    oldCellEditor.dispose();
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

  void onChange(dynamic pValue) {}

  void onEndEditing(dynamic pValue) {
    LOGGER.logI(pType: LOG_TYPE.DATA, pMessage: "Value of ${model.id} set to $pValue");
    // uiService.sendCommand() // TODO setValueS!!! command
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
}
