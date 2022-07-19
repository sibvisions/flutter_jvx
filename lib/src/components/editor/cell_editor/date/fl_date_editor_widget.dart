import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../model/component/editor/cell_editor/date/fl_date_editor_model.dart';
import '../../text_field/fl_text_field_widget.dart';

class FlDateEditorWidget<T extends FlDateEditorModel> extends FlTextFieldWidget<T> {
  const FlDateEditorWidget({
    Key? key,
    required T model,
    required FocusNode focusNode,
    required TextEditingController textController,
    required Function(String) valueChanged,
    required Function(String) endEditing,
    bool inTable = false,
  }) : super(
            key: key,
            model: model,
            valueChanged: valueChanged,
            endEditing: endEditing,
            focusNode: focusNode,
            textController: textController,
            inTable: inTable);

  @override
  List<Widget> createSuffixItems([bool pForceAll = false]) {
    List<Widget> oldSuffixItems = super.createSuffixItems(pForceAll);

    oldSuffixItems.add(Align(
      widthFactor: 1,
      heightFactor: 1,
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
