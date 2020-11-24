import 'package:flutter/material.dart';

import '../../utils/app/so_text_align.dart';
import 'component_widget.dart';
import 'models/text_field_component_model.dart';

class CoPasswordFieldWidget extends ComponentWidget {
  final TextFieldComponentModel componentModel;
  CoPasswordFieldWidget({this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoPasswordFieldWidgetState();
}

class CoPasswordFieldWidgetState
    extends ComponentWidgetState<CoPasswordFieldWidget> {
  TextEditingController textController = TextEditingController();
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    this.focusNode.addListener(() {
      if (!focusNode.hasFocus) widget.componentModel.onTextFieldEndEditing();
    });
  }

  void onTextFieldValueChanged(dynamic newValue) {
    this.setState(() {
      widget.componentModel.onTextFieldValueChanged(newValue);
    });
  }

  void onTextFieldEndEditing() {
<<<<<<< HEAD
    focusNode.unfocus();
    widget.componentModel.onTextFieldEndEditing();
=======
    TextUtils.unfocusCurrentTextfield(context);

    if (this.valueChanged) {
      SetComponentValue setComponentValue =
          SetComponentValue(this.name, text, this.appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(setComponentValue);
      this.valueChanged = false;
    }
>>>>>>> dev
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
                                this.textController.text.isNotEmpty) {
                              widget.componentModel.value = null;
                              widget.componentModel.valueChanged = true;
                              widget.componentModel.onTextFieldValueChanged(
                                  widget.componentModel.value);
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
            controller: textController,
            minLines: null,
            maxLines: 1,
            keyboardType: TextInputType.text,
            onEditingComplete: onTextFieldEndEditing,
            onChanged: onTextFieldValueChanged,
            focusNode: focusNode,
            readOnly: !widget.componentModel.enabled,
            obscureText: true),
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
