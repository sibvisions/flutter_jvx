import 'package:flutter/material.dart';

import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../text_field/fl_text_field_widget.dart';

class FlTextAreaWidget<T extends FlTextAreaModel> extends FlTextFieldWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaWidget(
      {Key? key,
      required T model,
      required Function(String) valueChanged,
      required Function(String) endEditing,
      required FocusNode focusNode,
      required TextEditingController textController})
      : super(
            key: key,
            model: model,
            valueChanged: valueChanged,
            endEditing: endEditing,
            focusNode: focusNode,
            textController: textController);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  int? get minLines => model.rows;

  @override
  int? get maxLines => null;

  @override
  TextInputType get keyboardType => TextInputType.multiline;
}
