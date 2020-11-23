import 'package:flutter/material.dart';

import '../../utils/app/so_text_align.dart';
import 'component_widget.dart';
import 'models/text_field_component_model.dart';

class CoTextFieldWidget extends ComponentWidget {
  final TextFieldComponentModel componentModel;

  CoTextFieldWidget({this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoTextFieldWidgetState();
}

class CoTextFieldWidgetState extends ComponentWidgetState<CoTextFieldWidget> {
  TextEditingController textController;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (widget.componentModel.text != null
        ? widget.componentModel.text.toString()
        : "");
    textController.value = textController.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return DecoratedBox(
      decoration: BoxDecoration(
          color: widget.componentModel.background != null
              ? widget.componentModel.background
              : Colors.white
                  .withOpacity(this.appState.applicationStyle?.controlsOpacity),
          borderRadius: BorderRadius.circular(
              this.appState.applicationStyle?.cornerRadiusEditors),
          border: widget.componentModel.border &&
                  widget.componentModel.enabled != null &&
                  widget.componentModel.enabled
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        child: TextFormField(
          textAlign: SoTextAlign.getTextAlignFromInt(
              widget.componentModel.horizontalAlignment),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12), border: InputBorder.none),
          style: TextStyle(
              color: widget.componentModel.enabled
                  ? (widget.componentModel.foreground != null
                      ? widget.componentModel.foreground
                      : Colors.black)
                  : Colors.grey[700]),
          controller: textController,
          minLines: null,
          maxLines: 1,
          keyboardType: TextInputType.text,
          onEditingComplete: () {
            widget.componentModel.onTextFieldEndEditing();
          },
          onChanged: widget.componentModel.onTextFieldValueChanged,
          focusNode: focusNode,
          readOnly: !widget.componentModel.enabled,
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
