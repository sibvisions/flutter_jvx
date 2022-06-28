import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/util/parse_util.dart';

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

  final bool inTable;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get iconSize {
    return ParseUtil.getTextHeight(text: "I", style: model.getTextStyle());
  }

  EdgeInsets? get textPadding => null;
  EdgeInsetsDirectional get iconPadding => const EdgeInsetsDirectional.only(end: 15);

  int? get minLines => null;

  int? get maxLines => model.rows;

  List<TextInputFormatter>? get inputFormatters => null;

  MaxLengthEnforcement? get maxLengthEnforcement => null;

  int? get maxLength => null;

  bool get obscureText => false;

  String get obscuringCharacter => '•';

  bool get showSuffixIcon => true;

  bool get hasSuffixItems => createSuffixItems().isNotEmpty;

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
    this.inTable = false,
  }) : super(key: key, model: model, valueChanged: valueChanged, endEditing: endEditing);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: model.placeholder,
        contentPadding: textPadding,
        border: const OutlineInputBorder(),
        enabledBorder: createBorder(),
        suffixIcon: createSuffixIcon(),
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
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget? createClearIcon() {
    if (textController.text.isEmpty) {
      return null;
    }

    return Align(
      widthFactor: 1,
      heightFactor: 1,
      alignment: keyboardType == TextInputType.multiline ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding: iconPadding,
        child: GestureDetector(
          onTap: () {
            if (focusNode.hasFocus) {
              valueChanged("");
            } else {
              endEditing("");
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

  List<Widget> createSuffixItems() {
    List<Widget> icons = [];

    Widget? clearIcon = createClearIcon();
    if (clearIcon != null) {
      icons.add(clearIcon);
    }

    return icons;
  }

  Widget? createSuffixIcon() {
    if (!showSuffixIcon || !hasSuffixItems) {
      return null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: createSuffixItems(),
    );
  }

  OutlineInputBorder createBorder() {
    if (inTable) {
      return const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      );
    }
    return OutlineInputBorder(
      borderSide: BorderSide(color: model.isEnabled ? themeData.primaryColor : IColorConstants.COMPONENT_DISABLED),
    );
  }
}
