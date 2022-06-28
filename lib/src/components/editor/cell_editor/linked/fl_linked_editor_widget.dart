import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';
import '../../text_field/fl_text_field_widget.dart';

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
    bool inTable = false,
  }) : super(
            key: key,
            model: model,
            valueChanged: valueChanged,
            endEditing: endEditing,
            focusNode: focusNode,
            textController: textController,
            keyboardType: TextInputType.none,
            inTable: inTable);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onPress, child: super.build(context));
  }

  @override
  List<Widget> createSuffixItems() {
    List<Widget> oldSuffixItems = super.createSuffixItems();

    oldSuffixItems.add(Align(
      widthFactor: 1,
      heightFactor: 1,
      alignment: keyboardType == TextInputType.multiline ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding: iconPadding,
        child: Icon(
          FontAwesomeIcons.sortDown,
          size: iconSize,
        ),
      ),
    ));

    return oldSuffixItems;
  }
}
