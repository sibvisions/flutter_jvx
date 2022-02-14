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

class FlEditorWrapperState<T extends FlEditorModel> extends BaseCompWrapperState<T>
    with UiServiceMixin, DataServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  late ICellEditor cellEditor;

  Widget dummyWidget = FlDummyWidget(id: "Dummy", model: FlDummyModel());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: cellEditor.widget);
  }

  @override
  void initState() {
    // Only exception where we actually have to do stuff BEFORE we init the sate...
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.
    cellEditor = ICellEditor.getCellEditor((widget.model as FlEditorModel).json);

    (widget.model as FlEditorModel).applyComponentInformation((cellEditor.widget as FlStatelessWidget).model);

    super.initState();
  }

  @override
  receiveNewModel({required T newModel}) {
    super.receiveNewModel(newModel: newModel);
  }
}
