import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';
import '../../text_field/fl_text_field_widget.dart';

class FlLinkedEditorWidget<T extends FlLinkedEditorModel> extends FlTextFieldWidget<T> {
  const FlLinkedEditorWidget({
    super.key,
    required super.model,
    required super.focusNode,
    required super.textController,
    required super.valueChanged,
    required super.endEditing,
    super.inTable,
    super.hideClearIcon,
  }) : super(keyboardType: TextInputType.none);

  @override
  List<Widget> createSuffixIconItems([bool pForceAll = false]) {
    List<Widget> oldSuffixItems = super.createSuffixIconItems(pForceAll);

    oldSuffixItems.add(
      Center(
        child: Icon(
          FontAwesomeIcons.caretDown,
          size: iconSize,
        ),
      ),
    );

    return oldSuffixItems;
  }
}
