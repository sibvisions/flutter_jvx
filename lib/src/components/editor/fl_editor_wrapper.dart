import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  @override
  void initState() {
    // Only exception where we actually have to do stuff BEFORE we init the sate...
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.

    (widget.model as FlEditorModel).applyComponentInformation((widget.model as T).cellEditor.getWidget().model);

    subscribe(widget.model as T);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: model.cellEditor.getWidget());
  }

  @override
  receiveNewModel({required T newModel}) {
    unsubcribe();

    (widget.model as FlEditorModel).applyComponentInformation((newModel.cellEditor.getWidget()).model);

    subscribe(newModel);

    super.receiveNewModel(newModel: newModel);
  }

  void subscribe(T model) {
    uiService.registerAsDataComponent(
        pDataProvider: model.dataRow,
        pCallback: model.cellEditor.setValue,
        pComponentId: model.id,
        pColumnName: model.columnName);
  }

  void unsubcribe() {
    uiService.unRegisterDataComponent(pComponentId: model.id, pDataProvider: model.dataRow);
  }
}
