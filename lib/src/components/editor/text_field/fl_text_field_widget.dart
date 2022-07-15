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

  final VoidCallback? onPress;

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  final bool inTable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get iconSize => 16;

  EdgeInsets? get textPadding => EdgeInsets.only(left: (inTable ? 0.0 : 5.0));

  EdgeInsets get iconPadding => const EdgeInsets.only(right: 15);

  double get iconToTextPadding => 5;

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
    this.onPress,
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
        enabledBorder: createBorder(context),
        suffixIcon: createSuffixIcon(),
      ),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
      textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
      readOnly: model.isReadOnly,
      enabled: model.isEnabled,
      style: model.getTextStyle(),
      onTap: onPress,
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
        child: InkWell(
          onTap: () {
            if (focusNode.hasFocus) {
              textController.clear();
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

    return Padding(
      padding: EdgeInsets.only(left: iconToTextPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: createSuffixItems(),
      ),
    );
  }

  OutlineInputBorder createBorder(context) {
    if (inTable) {
      return const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      );
    }
    return OutlineInputBorder(
      borderSide:
          BorderSide(color: model.isEnabled ? Theme.of(context).primaryColor : IColorConstants.COMPONENT_DISABLED),
    );
  }
}
