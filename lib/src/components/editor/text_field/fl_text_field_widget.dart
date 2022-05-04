import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../util/constants/i_color.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../model/layout/alignments.dart';
import '../../base_wrapper/fl_stateless_data_widget.dart';

class FlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessDataWidget<T, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get iconSize {
    TextPainter p = TextPainter(
      text: TextSpan(text: "I", style: model.getTextStyle()),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return p.height;
  }

  EdgeInsets get textPadding => const EdgeInsets.only(left: 12);

  EdgeInsets get iconPadding => const EdgeInsets.only(right: 5);

  int? get minLines => null;

  int? get maxLines => model.rows;

  List<TextInputFormatter>? get inputFormatters => null;

  MaxLengthEnforcement? get maxLengthEnforcement => null;

  int? get maxLength => null;

  bool get obscureText => false;

  String get obscuringCharacter => '•';

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWidget({
    Key? key,
    required T model,
    required Function(String) valueChanged,
    required Function(String) endEditing,
    required this.focusNode,
    required this.textController,
    this.keyboardType = TextInputType.text,
  }) : super(key: key, model: model, valueChanged: valueChanged, endEditing: endEditing);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: model.background,
        border: Border.all(
            color: model.isEnabled ? Theme.of(context).primaryColor : IColorConstants.COMPONENT_DISABLED,
            style: model.isBorderVisible ? BorderStyle.solid : BorderStyle.none),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          isDense: false, // Removes all the unneccessary paddings and widgets
          hintText: model.placeholder,
          contentPadding: textPadding,
          border: InputBorder.none,
          suffixIcon: ((!model.isReadOnly) && textController.text.isNotEmpty) ? getClearIcon() : null,
        ),
        textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
        textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
        readOnly: model.isReadOnly,
        style: model.getTextStyle(),
        onChanged: valueChanged,
        onEditingComplete: () {
          focusNode.unfocus();
        },
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        focusNode: !model.isReadOnly ? focusNode : null,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget? getClearIcon() {
    return Align(
      widthFactor: 1,
      alignment: keyboardType == TextInputType.multiline ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding: iconPadding,
        child: GestureDetector(
          onTap: () {
            textController.clear();

            if (focusNode.hasFocus) {
              valueChanged(textController.text);
            } else {
              endEditing(textController.text);
            }
          },
          child: Icon(
            Icons.clear,
            size: iconSize,
            color: IColorConstants.COMPONENT_DISABLED,
          ),
        ),
      ),
    );
  }
}
