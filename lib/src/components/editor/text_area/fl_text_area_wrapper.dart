import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../text_field/fl_text_field_wrapper.dart';
import 'fl_text_area_widget.dart';

class FlTextAreaWrapper extends BaseCompWrapperWidget<FlTextAreaModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaWrapper({Key? key, required String id}) : super(key: key, id: id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaWrapperState createState() => FlTextAreaWrapperState();
}

class FlTextAreaWrapperState extends FlTextFieldWrapperState<FlTextAreaModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlTextAreaWidget textAreaWidget = FlTextAreaWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: textAreaWidget);
  }
}
