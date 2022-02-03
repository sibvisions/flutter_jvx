import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/editor/fl_text_field_widget.dart';
import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlTextFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  const FlTextFieldWrapper({Key? key, required FlTextFieldModel model}) : super(key: key, model: model);

  @override
  _FlTextFieldWrapperState createState() => _FlTextFieldWrapperState();
}

class _FlTextFieldWrapperState extends BaseCompWrapperState<FlTextFieldModel> with UiServiceMixin, DataServiceMixin {
  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  @override
  receiveNewModel({required FlTextFieldModel newModel}) {
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
  Widget build(BuildContext context) {
    FlTextFieldWidget textFieldWidget = FlTextFieldWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: textFieldWidget);
  }

  void valueChanged(String pValue) {
    if (pValue != model.text) {
      log("Value changed to: " + pValue);

      setState(() {
        model.text = pValue;
      });
    }
  }

  void endEditing(String pValue) {
    log("Editing ended with: " + pValue);

    setState(() {
      model.text = pValue;
    });
  }

  void updateText() {
    textController.value = textController.value.copyWith(
      text: model.text,
      selection: TextSelection.collapsed(offset: model.text.characters.length),
      composing: null,
    );
  }
}
