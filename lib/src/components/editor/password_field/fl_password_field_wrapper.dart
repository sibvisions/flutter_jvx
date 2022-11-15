import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../text_field/fl_text_field_wrapper.dart';
import 'fl_password_field_widget.dart';

class FlPasswordFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPasswordFieldWrapper({super.key, required super.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPasswordFieldWrapperState createState() => FlPasswordFieldWrapperState();
}

class FlPasswordFieldWrapperState extends FlTextFieldWrapperState<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlPasswordWidget passwordWidget = FlPasswordWidget(
        model: model,
        valueChanged: valueChanged,
        endEditing: endEditing,
        focusNode: focusNode,
        textController: textController);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: passwordWidget);
  }
}
