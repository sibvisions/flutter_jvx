import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/editor/text_field/fl_text_field_widget.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlDateEditorWidget<T extends FlDateEditorModel> extends FlTextFieldWidget<T> {
  final VoidCallback? onPress;

  const FlDateEditorWidget({
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
            textController: textController);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onPress, child: super.build(context));
  }

  @override
  List<Widget> getSuffixItems() {
    List<Widget> oldSuffixItems = super.getSuffixItems();

    oldSuffixItems.add(Align(
      widthFactor: 1,
      alignment: keyboardType == TextInputType.multiline ? Alignment.topCenter : Alignment.center,
      child: Padding(
        padding: iconPadding,
        child: Icon(
          FontAwesomeIcons.calendar,
          size: iconSize,
        ),
      ),
    ));

    return oldSuffixItems;
  }
}
