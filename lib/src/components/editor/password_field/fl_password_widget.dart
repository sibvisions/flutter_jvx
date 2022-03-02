import 'package:flutter/material.dart';
import '../text_field/fl_text_field_widget.dart';
import '../../../model/component/text_field/fl_text_field_model.dart';

class FlPasswordWidget extends FlTextFieldWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPasswordWidget(
      {Key? key,
      required FlTextFieldModel model,
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
  bool get obscureText => true;
}
