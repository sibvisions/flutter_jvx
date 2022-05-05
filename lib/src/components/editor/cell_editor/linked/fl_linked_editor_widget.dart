import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/editor/text_field/fl_text_field_widget.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlLinkedEditorWidget<T extends FlLinkedEditorModel> extends FlTextFieldWidget<T> {
  final VoidCallback? onPress;

  const FlLinkedEditorWidget({
    Key? key,
    this.onPress,
    required T model,
    required Function(String) valueChanged,
    required Function(String) endEditing,
    required FocusNode focusNode,
    required TextEditingController textController,
  }) : super(
            key: key,
            model: model,
            valueChanged: valueChanged,
            endEditing: endEditing,
            focusNode: focusNode,
            textController: textController,
            keyboardType: TextInputType.none);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onPress, child: super.build(context));
  }

  @override
  Widget? get suffixIcon {
    Widget? oldSuffix = super.suffixIcon;

    Widget suffix = Align(
      widthFactor: 1,
      alignment: keyboardType == TextInputType.multiline ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding: iconPadding,
        child: Icon(
          FontAwesomeIcons.sortDown,
          size: iconSize,
        ),
      ),
    );

    if (oldSuffix == null) {
      return suffix;
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [oldSuffix, suffix],
      );
    }
  }
}
