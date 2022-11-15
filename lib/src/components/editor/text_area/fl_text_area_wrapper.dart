import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../flutter_jvx.dart';
import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../text_field/fl_text_field_widget.dart';
import '../text_field/fl_text_field_wrapper.dart';
import 'fl_text_area_dialog.dart';
import 'fl_text_area_widget.dart';

class FlTextAreaWrapper extends BaseCompWrapperWidget<FlTextAreaModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaWrapper({super.key, required super.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaWrapperState createState() => FlTextAreaWrapperState();
}

class FlTextAreaWrapperState extends FlTextFieldWrapperState<FlTextAreaModel> {
  double? calculatedRowSize;

  bool hasDialogOpen = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlTextAreaWidget textAreaWidget = FlTextAreaWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
      onDoubleTap: openDialogEditor,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: textAreaWidget);
  }

  @override
  Size calculateSize(BuildContext context) {
    Size size = super.calculateSize(context);

    double height = size.height;

    if (model.rows > 1) {
      height -= FlTextFieldWidget.DEFAULT_PADDING.vertical;
      calculatedRowSize ??= height;
      height = calculatedRowSize! * model.rows;
      height += FlTextFieldWidget.DEFAULT_PADDING.vertical;
    }

    return Size(size.width, height);
  }

  @override
  void endEditing(String pValue) {
    if (!hasDialogOpen) {
      super.endEditing(pValue);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void openDialogEditor() {
    TextEditingController temporaryController = TextEditingController.fromValue(textController.value);
    FocusNode temporaryFocusNode = FocusNode();
    bool hadFocus = focusNode.hasPrimaryFocus;

    hasDialogOpen = true;

    showDialog(
      context: FlutterJVx.getCurrentContext()!,
      builder: (context) {
        return FlTextAreaDialog(
          textController: temporaryController,
          focusNode: temporaryFocusNode,
          model: model,
          valueChanged: valueChanged,
          endEditing: endEditing,
        );
      },
    ).then((value) {
      hasDialogOpen = false;

      if (value == FlTextAreaDialog.CANCEL_OBJECT) {
        return;
      }

      if (temporaryController.text != textController.text) {
        if (hadFocus) {
          textController.value = temporaryController.value;
        } else {
          endEditing(temporaryController.text);
        }
      }

      temporaryController.dispose();
      temporaryFocusNode.dispose();
    });
  }
}
