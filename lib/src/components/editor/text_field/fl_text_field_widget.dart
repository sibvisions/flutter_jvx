import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/util/parse_util.dart';

import '../../../../main.dart';
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
    return ParseUtil.getTextHeight(text: "I", style: model.getTextStyle());
  }

  EdgeInsets get textPadding => const EdgeInsets.fromLTRB(12, 10, 0, 10);
  EdgeInsets get iconPadding => const EdgeInsets.fromLTRB(0, 10, 15, 10);

  int? get minLines => null;

  int? get maxLines => model.rows;

  List<TextInputFormatter>? get inputFormatters => null;

  MaxLengthEnforcement? get maxLengthEnforcement => null;

  int? get maxLength => null;

  bool get obscureText => false;

  String get obscuringCharacter => '•';

  bool get showSuffixIcon => true;

  bool get hasSuffixItems => getSuffixItems().isNotEmpty;

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
            color: model.isEnabled ? themeData.primaryColor : IColorConstants.COMPONENT_DISABLED,
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
          suffixIcon: getSuffixIcon(),
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
    if (textController.text.isEmpty) {
      return null;
    }

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

  List<Widget> getSuffixItems() {
    List<Widget> icons = [];

    Widget? clearIcon = getClearIcon();
    if (clearIcon != null) {
      icons.add(clearIcon);
    }

    return icons;
  }

  Widget? getSuffixIcon() {
    if (!showSuffixIcon || !hasSuffixItems) {
      return null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: getSuffixItems(),
    );
  }
}
