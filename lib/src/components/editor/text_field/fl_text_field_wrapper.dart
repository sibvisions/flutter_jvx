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

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/command/api/set_value_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../service/command/i_command_service.dart';
import '../../../util/parse_util.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_text_field_widget.dart';

class FlTextFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWrapper({super.key, required super.model});

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
  String lastSentValue = "";

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  FlTextFieldWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlTextFieldWidget widget = createWidget();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget);
  }

  @override
  modelUpdated() {
    super.modelUpdated();

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

      if (focusNode.hasFocus) {
        focus();
      } else {
        unfocus();
      }
    });
  }

  @override
  Size calculateSize(BuildContext context) {
    double averageColumnWidth = ParseUtil.getTextWidth(text: "w", style: model.createTextStyle());

    double width = averageColumnWidth * model.columns;

    width += createWidget().extraWidthPaddings();

    return Size(width, FlTextFieldWidget.TEXT_FIELD_HEIGHT);
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();

    super.dispose();
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
      hideClearIcon: model.hideClearIcon,
    );
    return textFieldWidget;
  }

  void valueChanged(String pValue) {
    setState(() {});
  }

  void endEditing(String pValue) {
    if (!model.isReadOnly && lastSentValue != pValue) {
      ICommandService()
          .sendCommand(
        SetValueCommand(
          componentName: model.name,
          value: pValue,
          reason: "Editing has ended on ${model.id}",
        ),
      )
          .then((success) {
        if (success) {
          lastSentValue = pValue;
        }
      });

      setState(() {});
    }
  }

  void updateText() {
    textController.value = textController.value.copyWith(
      text: model.text,
      selection: TextSelection.collapsed(offset: model.text.characters.length),
      composing: null,
    );
  }

  @override
  Future<BaseCommand?> createSaveCommand(String pReason) async {
    if (lastSentValue == textController.value.text) {
      return null;
    }

    lastSentValue = textController.value.text;
    return SetValueCommand(
      componentName: model.name,
      value: textController.value.text,
      reason: "$pReason; Editing has ended on ${model.id}",
    );
  }
}
