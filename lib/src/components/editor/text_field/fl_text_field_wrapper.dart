import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../util/parse_util.dart';
import '../../../model/command/api/set_value_command.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_text_field_widget.dart';

class FlTextFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextFieldWrapper({Key? key, required String id}) : super(key: key, id: id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextFieldWrapperState createState() => FlTextFieldWrapperState();
}

class FlTextFieldWrapperState<T extends FlTextFieldModel> extends BaseCompWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  late FlTextFieldWidget _lastBuiltTextfield;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    _lastBuiltTextfield = createWidget();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: _lastBuiltTextfield);
  }

  @override
  receiveNewModel({required T newModel}) {
    super.receiveNewModel(newModel: newModel);

    updateText();
  }

  @override
  void initState() {
    super.initState();

    updateText();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          endEditing(textController.text);
        });
      }
    });
  }

  @override
  Size calculateSize(BuildContext context) {
    Size size = super.calculateSize(context);

    double averageColumnWidth = ParseUtil.getTextWidth(text: "w", style: model.getTextStyle());

    double width = averageColumnWidth * model.columns;

    width += _lastBuiltTextfield.extraWidthPaddings();

    return Size(width, size.height);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextFieldWidget<FlTextFieldModel> createWidget() {
    FlTextFieldWidget textFieldWidget = FlTextFieldWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
    );
    return textFieldWidget;
  }

  void valueChanged(String pValue) {
    setState(() {});
  }

  void endEditing(String pValue) {
    SetValueCommand setValue =
        SetValueCommand(componentName: model.name, value: pValue, reason: "Editing has ended on ${model.id}");
    getUiService().sendCommand(setValue);

    setState(() {});
  }

  void updateText() {
    textController.value = textController.value.copyWith(
      text: model.text,
      selection: TextSelection.collapsed(offset: model.text.characters.length),
      composing: null,
    );
  }
}
