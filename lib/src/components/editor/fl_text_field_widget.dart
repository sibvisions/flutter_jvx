import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/components/label/fl_label_widget.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';

class FlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final Function(String) valueChanged;

  final Function(String) endEditing;

  final FocusNode focusNode;

  final TextEditingController textController;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWidget(
      {Key? key,
      required T model,
      required this.valueChanged,
      required this.endEditing,
      required this.focusNode,
      required this.textController})
      : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlLabelWidget labelWidget = FlLabelWidget(model: model);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: model.background,
        border: Border.all(
            color: model.isEnabled ? Colors.black : Colors.grey,
            style: model.isBorderVisible ? BorderStyle.solid : BorderStyle.none),
      ),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          isDense: true, // Removes all the unneccessary paddings and widgets
          hintText: model.placeholder,
          contentPadding: model.textPadding,
          border: InputBorder.none,
          suffixIcon: !model.isReadOnly && model.text.isNotEmpty ? getClearIcon() : null,
        ),
        textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
        textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
        readOnly: model.isReadOnly,
        style: labelWidget.getTextStyle(),
        onChanged: valueChanged,
        onEditingComplete: () {
          focusNode.unfocus();
        },
        minLines: null,
        maxLines: 1,
        keyboardType: TextInputType.text,
        focusNode: focusNode,
      ),
    );
  }

  Widget? getClearIcon() {
    return Padding(
      padding: model.iconPadding,
      child: GestureDetector(
        onTap: () {
          textController.value = textController.value.copyWith(
            text: "",
            selection: const TextSelection.collapsed(offset: 0),
            composing: TextRange.empty,
          );

          if (focusNode.hasFocus) {
            valueChanged(textController.text);
          } else {
            endEditing(textController.text);
          }
        },
        child: Icon(
          Icons.clear,
          size: model.iconSize,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
