import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_editor_model.dart';
import '../../../../util/jvx_colors.dart';
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

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;

    oldSuffixItems.add(
      Center(
        child: Icon(
          FontAwesomeIcons.caretDown,
          size: iconSize,
          color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
        ),
      ),
    );

    return oldSuffixItems;
  }
}
