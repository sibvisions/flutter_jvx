import 'package:flutter/material.dart';

import '../../utils/app/so_text_align.dart';
import 'component_widget.dart';
import 'models/text_area_component_model.dart';

class CoTextAreaWidget extends ComponentWidget {
  final TextAreaComponentModel componentModel;

  CoTextAreaWidget({this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoTextAreaWidgetState();
}

class CoTextAreaWidgetState extends ComponentWidgetState<CoTextAreaWidget> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (widget.componentModel.text != null
        ? widget.componentModel.text.toString()
        : "");
    _controller.value = _controller.value.copyWith(
        text: controllerValue,
        selection: TextSelection.collapsed(offset: controllerValue.length));

    return Container(
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: widget.componentModel.background != null
                ? widget.componentModel.background
                : Colors.white.withOpacity(
                    this.appState.applicationStyle?.controlsOpacity),
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
            controller: _controller,
            minLines: null,
            maxLines: 1,
            keyboardType: TextInputType.text,
            onEditingComplete: () {
              widget.componentModel.onTextFieldEndEditing();
            },
            onChanged: widget.componentModel.onTextFieldValueChanged,
            readOnly: !widget.componentModel.enabled,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
