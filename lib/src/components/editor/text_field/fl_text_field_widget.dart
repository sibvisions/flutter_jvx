import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_data_widget.dart';
import '../../label/fl_label_widget.dart';
import '../../../model/component/editor/fl_text_field_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../../util/constants/i_color.dart';

class FlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessDataWidget<T, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final FocusNode focusNode;

  final TextEditingController textController;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get iconSize => 24;

  EdgeInsets get textPadding => const EdgeInsets.only(left: 1);

  EdgeInsets get iconPadding => const EdgeInsets.only(right: 5);

  int? get minLines => null;

  int? get maxLines => model.rows;

  TextInputType get keyboardType => TextInputType.text;

  List<TextInputFormatter>? get inputFormatters => null;

  MaxLengthEnforcement? get maxLengthEnforcement => null;

  int? get maxLength => null;

  bool get obscureText => false;

  String get obscuringCharacter => '•';

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWidget(
      {Key? key,
      required T model,
      required Function(String) valueChanged,
      required Function(String) endEditing,
      required this.focusNode,
      required this.textController})
      : super(key: key, model: model, valueChanged: valueChanged, endEditing: endEditing);

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
            color: model.isEnabled ? Colors.black : IColorConstants.COMPONENT_DISABLED,
            style: model.isBorderVisible ? BorderStyle.solid : BorderStyle.none),
      ),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          isDense: true, // Removes all the unneccessary paddings and widgets
          hintText: model.placeholder,
          contentPadding: textPadding,
          border: InputBorder.none,
          suffixIcon: !model.isReadOnly && textController.text.isNotEmpty ? getClearIcon() : null,
        ),
        textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
        textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
        readOnly: model.isReadOnly,
        style: labelWidget.getTextStyle(),
        onChanged: valueChanged,
        onEditingComplete: () {
          focusNode.unfocus();
        },
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        focusNode: focusNode,
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
      alignment: Alignment.topCenter,
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
