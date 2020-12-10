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
    this.textController = TextEditingController();
    this.focusNode = FocusNode();
    this.focusNode.addListener(() {
      if (!this.focusNode.hasFocus)
        widget.componentModel.onTextFieldEndEditing(context);
    });
  }

  void onTextFieldValueChanged(dynamic newValue) {
    this.setState(() {
      widget.componentModel.onTextFieldValueChanged(newValue);
    });
  }

  void onTextFieldEndEditing() {
    this.focusNode.unfocus();
    widget.componentModel.onTextFieldEndEditing(context);
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (widget.componentModel.text != null
        ? widget.componentModel.text.toString()
        : "");
    this.textController.value = this.textController.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return DecoratedBox(
      decoration: BoxDecoration(
          color: widget.componentModel.background != null
              ? widget.componentModel.background
              : Colors.white.withOpacity(widget
                  .componentModel.appState.applicationStyle?.controlsOpacity),
          borderRadius: BorderRadius.circular(widget
              .componentModel.appState.applicationStyle?.cornerRadiusEditors),
          border: widget.componentModel.border &&
                  widget.componentModel.enabled != null &&
                  widget.componentModel.enabled
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        child: TextField(
          textAlign: SoTextAlign.getTextAlignFromInt(
              widget.componentModel.horizontalAlignment),
          decoration: InputDecoration(
              hintText: widget.componentModel.placeholder,
              contentPadding: widget.componentModel.textPadding,
              border: InputBorder.none,
              suffixIcon: widget.componentModel.enabled != null &&
                      widget.componentModel.enabled
                  ? Padding(
                      padding: widget.componentModel.iconPadding,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.componentModel.value != null &&
                              this.textController.text.isNotEmpty) {
                            widget.componentModel.text = null;
                            widget.componentModel.valueChanged = true;
                            widget.componentModel.onTextFieldValueChanged(
                                widget.componentModel.text);
                            widget.componentModel.valueChanged = false;
                          }
                        },
                        child: this.textController.text.isNotEmpty
                            ? Icon(Icons.clear,
                                size: widget.componentModel.iconSize,
                                color: Colors.grey[400])
                            : SizedBox(
                                height: widget.componentModel.iconSize,
                                width: 1),
                      ),
                    )
                  : null),
          style: TextStyle(
              color: widget.componentModel.enabled
                  ? (widget.componentModel.foreground != null
                      ? widget.componentModel.foreground
                      : Colors.black)
                  : Colors.grey[700]),
          controller: this.textController,
          minLines: null,
          maxLines: 1,
          keyboardType: TextInputType.text,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          focusNode: this.focusNode,
          readOnly: !widget.componentModel.enabled,
        ),
      ),
    );
  }

  @override
  void dispose() {
    this.textController.dispose();
    this.focusNode.dispose();
    super.dispose();
  }
}
