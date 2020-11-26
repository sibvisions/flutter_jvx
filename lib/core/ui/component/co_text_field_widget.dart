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
  @override
  void initState() {
    super.initState();
    widget.componentModel.textController = TextEditingController();
    widget.componentModel.focusNode = FocusNode();
    widget.componentModel.focusNode.addListener(() {
      if (!widget.componentModel.focusNode.hasFocus)
        widget.componentModel.onTextFieldEndEditing();
    });
  }

  void onTextFieldValueChanged(dynamic newValue) {
    this.setState(() {
      widget.componentModel.onTextFieldValueChanged(newValue);
    });
  }

  void onTextFieldEndEditing() {
    widget.componentModel.focusNode.unfocus();
    widget.componentModel.onTextFieldEndEditing();
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (widget.componentModel.text != null
        ? widget.componentModel.text.toString()
        : "");
    widget.componentModel.textController.value =
        widget.componentModel.textController.value.copyWith(
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
              contentPadding: widget.componentModel.textPadding,
              border: InputBorder.none,
              suffixIcon: widget.componentModel.enabled != null &&
                      widget.componentModel.enabled
                  ? Padding(
                      padding: widget.componentModel.iconPadding,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.componentModel.value != null &&
                              widget.componentModel.textController.text
                                  .isNotEmpty) {
                            widget.componentModel.value = null;
                            widget.componentModel.valueChanged = true;
                            widget.componentModel.onTextFieldValueChanged(
                                widget.componentModel.value);
                            widget.componentModel.valueChanged = false;
                          }
                        },
                        child:
                            widget.componentModel.textController.text.isNotEmpty
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
          controller: widget.componentModel.textController,
          minLines: null,
          maxLines: 1,
          keyboardType: TextInputType.text,
          onEditingComplete: onTextFieldEndEditing,
          onChanged: onTextFieldValueChanged,
          focusNode: widget.componentModel.focusNode,
          readOnly: !widget.componentModel.enabled,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.componentModel.textController.dispose();
    widget.componentModel.focusNode.dispose();
    super.dispose();
  }
}
